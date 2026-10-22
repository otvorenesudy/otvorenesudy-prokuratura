# frozen_string_literal: true

require 'roo'

module GenproGovSk
  module Criminality
    # A spreadsheet of the people accused, prosecuted or convicted by paragraph of the Criminal Code, for an office and
    # a year: the heading rows say which report, year, office and code it is, the row with the paragraphs heads their
    # columns, and the rows below it are the metrics.
    class ParagraphsParser
      PARAGRAPH = /\A§\s{0,1}[0-9a-zA-Z]+\z/
      CONVICTED = Regexp.union(
        'Odsúdené osoby za trestné činy',
        'Odsúdené osoby pre prečiny, zločiny',
        'Prehľad o osobách odsúdených pre trestné činy'
      )
      OFFICE = /Prehľad za.* ((?:OP|KP|GP).+)$/

      # Metrics the spreadsheet gives only in part, which the parser completes: the second of a pair from the total and
      # the first, and the totals from their parts.
      COMPLEMENTS = { 'girls' => 'boys', 'women' => 'men' }.freeze
      SUMMED = %i[accused_recidivists_all].freeze

      def self.parse(path)
        sheet = Roo::Spreadsheet.open(path).sheet(0)

        begin
          new(sheet.to_a).parse
        ensure
          sheet.close
        end
      end

      def initialize(rows)
        @rows = rows
        @columns = rows.find { |row| row.any? { |cell| cell.to_s.match?(PARAGRAPH) } }
        @paragraphs = @columns.to_a.each_with_index.to_h.select { |column, _| column.to_s.match?(PARAGRAPH) }
        @data = { statistics: [] }
        @unknown = []
        @previous_title = ''
      end

      def parse
        return if @paragraphs.blank? || !read_rows || @data[:statistics].blank?

        complete

        @data.merge(unknown: @unknown)
      end

      def self.normalize_office_name(value)
        value
          .gsub('OP', 'Okresná prokuratúra')
          .gsub('KP', 'Krajská prokuratúra')
          .gsub('-', ' - ')
          .tr('1', 'I')
          .gsub('2', 'II')
          .gsub('3', 'III')
          .gsub('4', 'IV')
          .tr('5', 'V')
          .gsub(%r{n/}, 'nad ')
          .gsub('GP SR', 'Generálna prokuratúra Slovenskej republiky')
      end

      def self.normalize_title(value, row:, rows:)
        title =
          value
          .gsub(/\A[[:space:]]+/, '- ')
          .gsub(/(\A[[:space:]]+|[[:space:]]+\z)/, '')
          .gsub(/[[:space:]]+/, ' ')
          .gsub(/\A[[:space:]]-/, '-')
          .gsub(/(z toho:)/, '-')
          .gsub(/[[:space:]]+z toho/, '-')
          .tr('–', '-')
          .gsub('Obžalované osoby', 'Obžalovaných osôb')
          .squeeze('-')

        # A row of girls belongs to the row above it.
        return title unless title.include?('- dievčatá')

        "#{normalize_title(rows[rows.index(row) - 1][0], row:, rows:)} #{title}"
      end

      def self.parse_count(value)
        count = value.to_s.gsub(/[[:space:]]/, '').gsub(/\..*\z/, '')

        count.presence ? Integer(count.presence) : nil
      end

      private

      # False when the rows below the paragraphs belong to no report the parser knows.
      def read_rows
        @rows.all? do |row|
          title = self.class.normalize_title(row[0].to_s.gsub(/(\A[[:space:]]|[[:space:]]\z)/, ''), row:, rows: @rows)

          read_heading(title)

          next true if @rows.index(row) <= @rows.index(@columns)
          next false if @data[:report].blank?

          read_statistics(row, title)
          true
        end
      end

      def read_heading(title)
        @data[:report] = :convicted if CONVICTED.match?(title)
        @data[:report] = :accused_and_prosecuted if title.include?('Prehľad o stíhaných a obžalovaných osobách')
        @data[:year] = title.match(/\d{4}/)[0].to_i if /obdobie/i.match?(title)
        @data[:office] = OFFICES_MAP[title[/\d{4}/]] if title.include?('Prokuratúry')

        office = title[OFFICE, 1]
        @data[:office] ||= self.class.normalize_office_name(office) if office

        read_type(title)
      end

      def read_type(title)
        @data[:type] = :old if title.include?('podľa paragrafov trestného zákona do roku 2005')
        @data[:type] = :new if title.include?('podľa paragrafov trestného zákona od roku 2006')
        @data[:type] = (title.include?('Nie') ? :new : :old) if title.include?('Podľa TZ 2005')
      end

      # A metric's row, a count per paragraph; a title starting with a dash is a part of the title above it.
      def read_statistics(row, title)
        if title.start_with?('-')
          title = "#{@previous_title} #{title}"
        else
          @previous_title = title
        end

        metric = metrics[title]

        if metric
          @paragraphs.each do |paragraph, index|
            count = self.class.parse_count(row[index])

            @data[:statistics] << { metric:, paragraph: "#{paragraph} [#{@data[:type]}]", count: }
          end
        elsif title.present?
          @unknown << title
        end
      end

      def metrics
        { accused_and_prosecuted: PARAGRAPHS_BY_ACCUSED_AND_PROSECUTED_MAP, convicted: PARAGRAPHS_BY_CONVICTED_MAP }
          .fetch(@data[:report])
      end

      def complete
        @data[:statistics].each do |statistic|
          COMPLEMENTS.each { |part, complement| add_complement(statistic, part, complement) }
        end

        # The reports have no row for these totals.
        SUMMED.each do |metric|
          @data[:statistics].map { |e| e[:paragraph] }.uniq.each { |paragraph| add_sum(metric, paragraph) }
        end
      end

      def add_complement(statistic, part, complement)
        metric, paragraph, count = statistic.values_at(:metric, :paragraph, :count)

        return unless metric.to_s.end_with?("_#{part}")

        base = metric.to_s.delete_suffix("_#{part}")
        total = find(:"#{base}_all", paragraph)

        return if total.nil? || total[:count].nil? || find(:"#{base}_#{complement}", paragraph)

        @data[:statistics] << { metric: :"#{base}_#{complement}", paragraph:, count: total[:count] - (count || 0) }
      end

      def add_sum(metric, paragraph)
        base = metric.to_s.delete_suffix('_all')
        parts =
          @data[:statistics].select do |e|
            e[:metric].match?(/\A#{base}_\w+\z/) && e[:metric] != metric && e[:paragraph] == paragraph && e[:count]
          end

        return if parts.blank?

        @data[:statistics] << { metric:, paragraph:, count: parts.sum { |e| e[:count] } }
      end

      def find(metric, paragraph)
        @data[:statistics].find { |e| e[:metric] == metric && e[:paragraph] == paragraph }
      end
    end
  end
end
