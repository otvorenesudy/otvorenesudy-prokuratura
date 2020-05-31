require 'active_support'
require 'legacy'

module GenproGovSk
  module Prosecutors
    module Parser
      def self.parse(text)
        text = cleanup(text)
        lines = text.split("\n").map(&:strip).select(&:present?)

        lines.each.with_object([]) { |line, array| array << parse_line(line) }
      end

      class << self
        private

        def cleanup(text)
          text.gsub!(%r{Priezvisko meno, titul\/-y}, '')
          text.gsub!(/Pravidelné miesto výkonu funkcie/, '')
          text.gsub!(/Dočasné pridelenie/, '')

          text
        end

        def parse_line(line)
          _, number = *line.match(/\A(\d+)/)

          line.gsub!(/\A\d+/, '')

          parts = line.split(/\s{3,}/)

          name = parse_name(parts[0])
          office = parts[1].strip
          temporary_office = parts[2]&.strip

          { number: number, name: name, office: office, tempary_office: temporary_office }
        end

        def parse_name(value)
          Legacy::Normalizer.normalize_person_name(value, reverse: true)
        end
      end
    end
  end
end
