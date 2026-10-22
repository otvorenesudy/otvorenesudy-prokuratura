# frozen_string_literal: true

require 'csv'

module GenproGovSk
  module Criminality
    class StructureParser
      # Metrics the table sums from their parts when it lacks their total.
      SUMMED = %i[accused_recidivists_all].freeze

      def self.parse(text)
        csv = CSV.parse(text, col_sep: ';')
        year = csv[0][0].match(/\d{2}.\d{2}.(\d{4})/)[1]
        unknown = []
        offices = GenproGovSk::Criminality::OFFICES_MAP.to_h { |key, name| [name, csv[0].index(key)] }

        offices.map do |name, index|
          statistics = parse_statistics(csv, index, unknown)

          SUMMED.each do |metric|
            calculate_sum_count(statistics, metric:, count: statistics.find { |e| e[:metric] == metric }&.dig(:count))
          end

          { office: name, year:, statistics:, unknown: unknown.uniq }
        end
      end

      # The office's column of the table; a row without a title of its own continues the title above it.
      def self.parse_statistics(csv, index, unknown)
        last_title = nil

        csv.filter_map do |row|
          next if row[0].blank? && row[1].blank?

          last_title = row[0] if row[0].present?
          title = normalize_metric(row[0].presence || [last_title, row[1]].join(' '))

          next if ignore_title?(title)

          metric = GenproGovSk::Criminality::STRUCTURES_MAP[title]
          unknown << title if metric.nil? && title.present?

          { metric:, count: parse_count(row[index]) } if metric
        end
      end

      def self.normalize_metric(value)
        value.to_s.gsub(/[[:space:]]+/, ' ').gsub(/odstíhaných/, 'stíhaných').strip
      end

      def self.parse_count(value)
        count = value.to_s.gsub(/[[:space:]]/, '')

        count.presence ? Integer(count) : nil
      end

      def self.calculate_sum_count(statistics, metric:, count:)
        return if !metric.to_s.end_with?('_all') || count

        base = metric.to_s.delete_suffix('_all').to_sym
        children = statistics.select { |e| e[:metric].match(/\A#{base}_\w+\z/) && e[:metric] != metric && e[:count] }

        return if children.blank?

        statistics << { metric: metric, count: children.sum { |e| e[:count] } }
      end

      def self.ignore_title?(title)
        return true if title.match(/Skladba trestných (pre)?činov/) && title.match(/(hlava|hláv)/)
        return true if title.start_with?('Za obdobie:')
        return true if title == 'Skladba stíhaných osôb'
        return true if /\APočet spáchaných trestných činov/.match?(title)

        true if /\APočet spáchaných prečinov/.match?(title)
      end
    end
  end
end
