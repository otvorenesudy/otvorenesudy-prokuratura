require 'p_d_f_extractor'

module GenproGovSk
  class ImportPdfDecreeJob < ApplicationJob
    queue_as :genpro_gov_sk_pdf_decrees

    def perform(data)
      text, file = PDFExtractor.extract_text_from_url(data[:url])

      GenproGovSk::Decree.import_from(data: data.merge(text: text), file: file)
    end
  end
end
