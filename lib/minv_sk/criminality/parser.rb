require 'csv'

module MinvSk
  module Criminality
    module Parser
      def self.parse(csv)
        csv = csv.force_encoding('Windows-1250').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')

        rows = CSV.parse(csv, headers: true, col_sep: ',')

        year = rows[0][0].match(/\.(\d{4})/)[1].to_i
        codex = rows[0][0].match(/1961/) ? :old : :new
        breakdowns = [
          *map_breakdowns(rows[5][1..13], CRIME_MAP, base_column: 1),
          *map_breakdowns(rows[5][14..-2], PERSONS_MAP, base_column: 14)
        ]

        data = []

        rows[6..-1].each do |row|
          next unless row[0] && row[0].match(/§\s+\d+/)

          paragraph = row[0].gsub(/[-]+/, '').gsub(/[[:space:]]+/, ' ').gsub(%r{/\d+\z}, '').strip

          breakdowns.each do |breakdown|
            data << {
              year: year,
              paragraph: "#{paragraph} [#{codex}]",
              metric: breakdown[:value],
              count: row[breakdown[:column]].gsub(/[[:space:]]+/, '').to_i
            }
          end
        end

        data
      end

      private

      def self.map_breakdowns(breakdowns, map, base_column:)
        breakdowns
          .map
          .with_index do |breakdown, i|
            breakdown.gsub!(/(\A[[:space:]]+|[[:space:]]+\z)/, '')

            next if breakdown.blank? || breakdown.in?(['t.j. %'])

            breakdown.gsub!(/\s*?-\s*?/, ' - ')

            mapped_breakdown = map[breakdown]

            raise "Unknown breakdown: #{breakdown}" unless mapped_breakdown

            { value: mapped_breakdown, column: base_column + i }
          end
          .compact
      end
    end
  end
end
