require 'rails_helper'

RSpec.describe GenproGovSk::Prosecutors::PDFParser do
  let(:pdf_path) { Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'prosecutors', 'list.pdf').to_s }
  let(:expected_json) do
    JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'prosecutors', 'list.json')))
  end

  describe '.parse' do
    it 'extracts rows from the PDF correctly' do
      rows = described_class.parse(pdf_path)

      expect(rows.size).to eq(expected_json.size)
      expect(rows).to eq(expected_json)
    end
  end
end
