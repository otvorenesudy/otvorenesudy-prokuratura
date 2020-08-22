require 'roo'

module GenproGovSk
  module Criminality
    class ParagraphsParser
      def self.parse(path)
        xls = Roo::Spreadsheet.open(path)
        sheet = xls.sheet(0)
        rows = sheet.to_a
        columns = rows.find { |e| e.any? { |e| e.to_s.match(/\A§\s{0,1}[0-9a-zA-Z]+\z/) } }
        previous_key = ''

        paragraphs =
          if columns
            columns.each.with_object({}).with_index do |(column, hash), i|
              hash[column] = i if column.to_s.match(/\A§\s{0,1}[0-9a-zA-Z]+\z/)
            end
          end

        return {} if paragraphs.blank?

        data =
          rows.each.with_object({ statistics: [] }) do |row, data|
            key = normalize_key(row[0].to_s.gsub(/(\A[[:space:]]|[[:space:]]\z)/, ''))

            # Year
            #
            data[:year] = key.match(/\d{4}/)[0].to_i if key.match(/obdobie/i)

            # Office
            #
            data[:office] = OFFICES_MAP[key.match(/\d{4}/).to_a[0]] if key.match(/Prokuratúry/)

            if key.match(/Prehľad za.* ((OP|KP).+)$/) && data[:office].nil?
              _, value = *key&.match(/Prehľad za.* ((OP|KP).+)$/)

              next if key.match(/Prehľad za OP Šaľa/)

              data[:office] ||= normalize_office_name(value)
            end

            # Type
            #
            data[:type] = :old if key.match(/podľa paragrafov trestného zákona do roku 2005/)
            data[:type] = :new if key.match(/podľa paragrafov trestného zákona od roku 2006/)
            data[:type] = key.match(/Nie/) ? :new : :old if key.match(/Podľa TZ 2005/)

            # Statistics
            #
            next unless rows.index(row) > rows.index(columns)

            data[:no_value_filters] ||= []
            data[:unknown_filters] ||= []

            if key.starts_with?('-')
              key = "#{previous_key} #{key}"
            else
              previous_key = key
            end

            filter = PARAGRAPHS_MAP[key]

            next unless filter

            paragraphs.each do |paragraph, index|
              paragraph = "#{paragraph} [#{data[:type]}]"

              count = parse_count(row[index])

              data[:statistics] << { filters: [paragraph, filter], count: count }
            end
          end

        data[:statistics].each do |statistic|
          paragraph, filter = *statistic[:filters]
          count = statistic[:count]

          calculate_complemental_count(
            data,
            paragraph: paragraph, filter: filter, count: count, from: 'girls', to: 'boys'
          )
          calculate_complemental_count(
            data,
            paragraph: paragraph, filter: filter, count: count, from: 'women', to: 'men'
          )
        end

        sheet.close

        data
      end

      def self.calculate_complemental_count(data, paragraph:, filter:, count:, from:, to:)
        return unless filter.to_s.match(/_#{from}\z/)

        base = filter.to_s.gsub(/_#{from}\z/, '').to_sym
        all = :"#{base}_all"
        sum = data[:statistics].find { |e| e[:filters] == [paragraph, all] }

        return if !sum || !sum[:count] || data[:statistics].find { |e| e[:filters] == [paragraph, :"#{base}_#{to}"] }

        data[:statistics] << { filters: [paragraph, :"#{base}_#{to}"], count: sum[:count] - (count || 0) }
      end

      def self.normalize_office_name(value)
        value.gsub(/OP/, 'Okresná prokuratúra').gsub(/KP/, 'Krajská prokuratúra').gsub(/-/, ' - ').gsub(/1/, 'I').gsub(
          /2/,
          'II'
        ).gsub(/3/, 'III').gsub(/4/, 'IV').gsub(/5/, 'V').gsub(%r{n\/}, 'nad ')
      end

      def self.normalize_key(value)
        value.gsub(/(\A[[:space]]+|[[:space:]]+\z)/, '').gsub(/[[:space:]]+/, ' ').gsub(/\A[[:space]]-/, '-').gsub(
          /(z toho:)/,
          '-'
        ).gsub(/[[:space:]]+z toho/, '-').gsub(/–/, '-').gsub(/Obžalované osoby/, 'Obžalovaných osôb').gsub(
          /-{1,}/,
          '-'
        )
      end

      def self.parse_count(value)
        count = value.to_s.gsub(/[[:space:]]/, '').gsub(/\..*\z/, '')

        count.presence ? Integer(count.presence) : nil
      end
    end
  end
end
