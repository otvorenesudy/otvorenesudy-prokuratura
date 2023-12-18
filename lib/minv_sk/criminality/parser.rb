require 'csv'

SKK_TO_EUR_BY_YEAR = {
  1993 => 37.219,
  1994 => 38.086,
  1995 => 37.872,
  1996 => 39.55,
  1997 => 38.372,
  1998 => 43.29,
  1999 => 42.458,
  2000 => 43.996,
  2001 => 42.76,
  2002 => 41.722,
  2003 => 41.161,
  2004 => 38.796,
  2005 => 37.848,
  2006 => 34.573,
  2007 => 33.603,
  2008 => 30.126
}

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
            value = row[breakdown[:column]].gsub(/[[:space:]]+/, '').to_i

            if breakdown[:value] == :crime_denominated_damage
              value *= 1000
              value = convert_skk_to_eur(value, year: year) if year < 2009
            end

            data << { year: year, paragraph: "#{paragraph} [#{codex}]", metric: breakdown[:value], count: value }
          end
        end

        data
      end

      class << self
        private

        def convert_skk_to_eur(value, year:)
          denominator =
            (
              if SKK_TO_EUR_BY_YEAR[year]
                SKK_TO_EUR_BY_YEAR[year]
              else
                (year < 1993 ? SKK_TO_EUR_BY_YEAR[1993] : SKK_TO_EUR_BY_YEAR[2008])
              end
            )

          (value / denominator.to_f).round(2)
        end

        def map_breakdowns(breakdowns, map, base_column:)
          breakdowns
            .map
            .with_index do |breakdown, i|
              breakdown.gsub!(/(\A[[:space:]]+|[[:space:]]+\z)/, '')

              next if breakdown.blank? || breakdown.in?(['t.j. %'])

              breakdown.gsub!(/\s*?-\s*?/, ' - ')

              mapped_breakdown = map[breakdown]

              raise "Unknown breakdown: #{breakdown}" unless mapped_breakdown

              value = base_column + i

              { value: mapped_breakdown, column: base_column + i }
            end
            .compact
        end
      end
    end
  end
end
