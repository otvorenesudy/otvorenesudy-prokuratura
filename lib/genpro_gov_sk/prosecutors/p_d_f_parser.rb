# frozen_string_literal: true

module GenproGovSk
  module Prosecutors
    module PDFParser
      def self.parse(path)
        pages = Iguvium.read(path)
        tables = pages.map { |page| page.extract_tables!.first }

        tables
          .flat_map(&:to_a)
          .map { |row| row.filter_map(&:presence) }
          .reject { |row| row[0] =~ /^Priezvisko meno/i }
      end
    end
  end
end
