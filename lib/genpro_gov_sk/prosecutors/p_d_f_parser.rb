module GenproGovSk
  module Prosecutors
    module PDFParser
      def self.parse(path)
        pages = Iguvium.read(path)
        tables = pages.map { |page| page.extract_tables!.first }

        tables
          .map { |table| table.to_a }
          .flatten(1)
          .reject { |row| row[0].to_s.strip.empty? || row[0] =~ /^Priezvisko meno/i }
      end
    end
  end
end
