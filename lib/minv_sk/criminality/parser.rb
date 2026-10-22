# frozen_string_literal: true

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
}.freeze

module MinvSk
  module Criminality
    module Parser
      def self.parse(csv)
        csv = csv.force_encoding('Windows-1250').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
        rows = CSV.parse(csv, headers: true, col_sep: ',')
        year = rows[0][0].match(/\.(\d{4})/)[1].to_i
        codex = rows[0][0].include?('1961') ? :old : :new
        breakdowns = [
          *map_breakdowns(rows[5][1..13], CRIME_MAP, base_column: 1),
          *map_breakdowns(rows[5][14..-2], PERSONS_MAP, base_column: 14)
        ]

        rows[6..].select { |row| row[0]&.match?(/§\s+\d+/) }.flat_map do |row|
          parse_row(row, breakdowns, year:, codex:)
        end
      end

      class << self
        private

        # A paragraph's row: a count for each breakdown.
        def parse_row(row, breakdowns, year:, codex:)
          paragraph = "#{row[0].delete('-').gsub(/[[:space:]]+/, ' ').gsub(%r{/\d+\z}, '').strip} [#{codex}]"

          breakdowns.map do |breakdown|
            count = count(row[breakdown[:column]], breakdown[:value], year)

            { year:, paragraph:, metric: breakdown[:value], count: }
          end
        end

        # Damages are in thousands, of Slovak crowns until 2008.
        def count(cell, metric, year)
          value = cell.gsub(/[[:space:]]+/, '').to_i

          return value unless metric == :crime_denominated_damage

          year < 2009 ? convert_skk_to_eur(value * 1000, year:) : value * 1000
        end

        def convert_skk_to_eur(value, year:)
          # The rate of 1993 before it, of 2008 after it.
          (value / SKK_TO_EUR_BY_YEAR[year.clamp(1993, 2008)].to_f).round(2)
        end

        def map_breakdowns(breakdowns, map, base_column:)
          breakdowns.each_with_index.filter_map do |breakdown, i|
            breakdown = breakdown.gsub(/(\A[[:space:]]+|[[:space:]]+\z)/, '')

            next if breakdown.blank? || breakdown == 't.j. %'

            breakdown = breakdown.gsub(/\s*?-\s*?/, ' - ')

            raise "Unknown breakdown: #{breakdown}" unless map[breakdown]

            { value: map[breakdown], column: base_column + i }
          end
        end
      end
    end
  end
end
