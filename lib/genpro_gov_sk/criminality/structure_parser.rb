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

          data =
            csv.map do |row|
              last_title = row[0] if row[0]&.strip.presence
              title = normalize_filter(row[0]&.strip.presence ? row[0] : [last_title, row[1]].join(' '))

              filter = GenproGovSk::Criminality::STRUCTURES_MAP[title]

              next unless filter

              count = parse_count(row[index])

              next unless count

              { filters: [filter], count: count }
            end

          { name: name, year: year, data: data.compact }
        end
      end

      def self.normalize_filter(value)
        value.to_s.gsub(/[[:space:]]+/, ' ').strip
      end

      def self.parse_count(value)
        count = value.to_s.gsub(/[[:space:]]/, '')

        count.presence ? Integer(count) : nil
      end
    end
  end
end
