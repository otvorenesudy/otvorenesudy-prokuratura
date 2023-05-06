require 'p_d_f_extractor'
require 'r_t_f_extractor'

module GenproGovSk
  class ImportDecreeJob < ApplicationJob
    queue_as :default

    def perform(data)
      text, file = PDFExtractor.extract_text_from_url(data[:url]) if data[:file_type] === 'pdf'
      text, file = RTFExtractor.extract_text_from_url(data[:url]) if data[:file_type] === 'rtf'

      raise ArgumentError.new("Unknown decree type: [${#{data[:type]}}]") unless text

      GenproGovSk::Decree.import_from(data: data.merge(text: text), file: file)
    end
  end
end
