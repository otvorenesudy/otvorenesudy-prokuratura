require 'csv'

module GenproGovSk
  module Criminality
    class StructureParser
      def self.parse(text)
        csv = CSV.parse(text, col_sep: ';')
        year = csv[0][0].match(/\d{2}.\d{2}.(\d{4})/)[1]
        offices =
          GenproGovSk::Criminality::OFFICES_MAP.each.with_object({}) do |(key, name), hash|
            hash[name] = csv[0].index(key)
          end

        offices.map do |name, index|
          last_title = nil

          statistics =
            csv.map do |row|
              last_title = row[0] if row[0]&.strip.presence
              title = normalize_filter(row[0]&.strip.presence ? row[0] : [last_title, row[1]].join(' '))

              filter = GenproGovSk::Criminality::STRUCTURES_MAP[title]

              next unless filter

              count = parse_count(row[index])

              { filters: [filter], count: count }
            end.compact

          %i[accused_recidivists_all].each do |filter|
            count = statistics.find { |e| e[:filters] == [filter] }.try { |e| %i[count] }

            calculate_sum_count(statistics, filter: filter, count: count)
          end

          { office: name, year: year, statistics: statistics }
        end
      end

      def self.normalize_filter(value)
        value.to_s.gsub(/[[:space:]]+/, ' ').gsub(/odstíhaných/, 'stíhaných').strip
      end

      def self.parse_count(value)
        count = value.to_s.gsub(/[[:space:]]/, '')

        count.presence ? Integer(count) : nil
      end

      def self.calculate_sum_count(statistics, filter:, count:)
        return if !filter.to_s.match(/_all\z/) || count

        base = filter.to_s.gsub(/_all\z/, '').to_sym
        children =
          statistics.select { |e| e[:filters][0].match(/\A#{base}_\w+\z/) && e[:filters][0] != filter && e[:count] }

        return if children.blank?

        statistics << { filters: [filter], count: children.map { |e| e[:count] }.sum }
      end
    end
  end
end
