require 'csv'

module GenproGovSk
  module Criminality
    class Parser
      def self.parse(text)
        csv = CSV.parse(text, col_sep: ';')
        year = csv[0][0].match(/\d{2}.\d{2}.(\d{4})/)[1]
        offices =
          GenproGovSk::Criminality::OFFICES_MAP.each.with_object({}) do |(key, name), hash|
            hash[name] = csv[0].index(key)
          end

        offices.map do |name, column|
          statistics = [PeopleFilter.process(csv, column: column), ClosureFilter.process(csv, column: column)].compact

          { office: name, statistics: statistics }
        end
      end

      class PeopleFilter
        def self.process(csv, column:)
          row = csv.find { |e| e[0] == 'Skladba odstíhaných osôb' }
          values = ParseSublist.parse(csv, row: row, column: column)

          { type: :people, values: values }
        end
      end

      class ClosureFilter
        def self.process(csv, column:); end
      end

      class ParseSublist
        def self.parse(csv, row:, column:)
          i = csv.index(row) + 1
          result = {}

          while !csv[i][0].presence
            value = csv[i][column]

            result[csv[i][1].strip] = Integer(value.gsub(/[[:space:]]/, '')) if value

            i += 1
          end

          result
        end
      end
    end
  end
end
