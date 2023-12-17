require 'r_t_f_extractor'

module GenproGovSk
  class ImportRtfDecreeJob < ApplicationJob
    queue_as :genpro_gov_sk_rtf_decrees

    def perform(data)
      text, file = RTFExtractor.extract_text_from_url(data[:url])

      GenproGovSk::Decree.import_from(data: data.merge(text: text, file_info: 'TODO'), file: file)
    end
  end
end
