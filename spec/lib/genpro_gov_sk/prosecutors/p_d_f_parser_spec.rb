require 'rails_helper'

RSpec.describe GenproGovSk::Prosecutors::PDFParser do
  describe '.parse' do
    it 'extracts rows from the PDF correctly' do
      pdf_path = Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'prosecutors', 'list.pdf').to_s
      expected_json =
        JSON.parse(
          File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'prosecutors', 'list.json'))
        )

      rows = described_class.parse(pdf_path)

      expect(rows.size).to eq(expected_json.size)
      expect(rows).to eq(expected_json)
    end

    it 'extracts prosecutor names, offices, and temporary offices' do
      pdf_path = Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'prosecutors', 'list.pdf').to_s

      rows = described_class.parse(pdf_path)

      expect(rows).to be_an(Array)
      expect(rows.size).to be > 1000

      expect(rows.first).to be_an(Array)
      expect(rows.first.size).to eq(3)
      expect(rows.first[0]).to match(/\w+.*,.*JUDr\./)
      expect(rows.first[1]).to be_a(String)
      expect(rows.first[2]).to be_a(String)
    end

    it 'excludes header rows' do
      pdf_path = Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'prosecutors', 'list.pdf').to_s

      rows = described_class.parse(pdf_path)

      expect(rows).not_to include(have_attributes(first: /Priezvisko meno/i))
    end
  end
end
