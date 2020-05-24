require 'p_d_f_extractor'

module GenproGovSk
  module Prosecutors
    def self.all
      text, file =
        PDFExtractor.extract_text_from_url(
          'https://www.genpro.gov.sk/extdoc/54888/Menny%20zoznam%20prokuratorov%20SR%20k%2015_05_2020'
        )

      data = Parser.parse(text)

      GenproGovSk::Prosecutor.import_from(data: data, file: file)
    end
  end
end