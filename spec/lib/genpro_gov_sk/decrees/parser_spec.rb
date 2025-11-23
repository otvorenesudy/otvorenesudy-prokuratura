require 'rails_helper'

RSpec.describe GenproGovSk::Decrees::Parser do
  describe '.parse' do
    context 'with page containing PDF files' do
      it 'parses page 1 correctly' do
        html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'decrees', 'page_1.html'))
        decrees = described_class.parse(html, url: 'https://www.genpro.gov.sk/')

        expect(decrees).to be_an(Array)
        expect(decrees.size).to eq(20)

        first_decree = decrees.first
        expect(first_decree[:url]).to eq('https://www.genpro.gov.sk//download/uznesenie/2025/11/za_5511_997_11_2025_a_2fc7888a717949c39beaa8e2f743f2b8.pdf')
        expect(first_decree[:number]).to eq('ZA/5511/997/11/2025')
        expect(first_decree[:effective_on]).to eq(Date.new(2025, 11, 19))
        expect(first_decree[:published_on]).to eq(Date.new(2025, 11, 19))
        expect(first_decree[:file_number]).to eq('1 Pv 53/25/5511')
        expect(first_decree[:resolution]).to eq('Uznesenie o schválení zmieru')
        expect(first_decree[:means_of_resolution]).to eq('zmier schválený a zastavenie trestného stíhania - § 220 s poukazom na § 215/ 1g Tr.por.')
        expect(first_decree[:file_type]).to eq('pdf')
      end

      it 'parses page 50 correctly' do
        html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'decrees', 'page_50.html'))
        decrees = described_class.parse(html, url: 'https://www.genpro.gov.sk/')

        expect(decrees).to be_an(Array)
        expect(decrees.size).to eq(20)

        decrees.each do |decree|
          expect(decree).to have_key(:url)
          expect(decree).to have_key(:number)
          expect(decree).to have_key(:effective_on)
          expect(decree).to have_key(:published_on)
          expect(decree).to have_key(:file_number)
          expect(decree).to have_key(:resolution)
          expect(decree).to have_key(:means_of_resolution)
          expect(decree).to have_key(:file_type)
          expect(decree[:file_type]).to eq('pdf')
        end
      end

      it 'parses page 100 correctly' do
        html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'decrees', 'page_100.html'))
        decrees = described_class.parse(html, url: 'https://www.genpro.gov.sk/')

        expect(decrees).to be_an(Array)
        expect(decrees.size).to eq(20)

        decrees.each do |decree|
          expect(decree[:file_type]).to eq('pdf')
          expect(decree[:effective_on]).to be_a(Date)
          expect(decree[:published_on]).to be_a(Date)
        end
      end
    end

    context 'with page containing RTF files' do
      it 'parses page 2000 correctly' do
        html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'decrees', 'page_2000.html'))
        decrees = described_class.parse(html, url: 'https://www.genpro.gov.sk/')

        expect(decrees).to be_an(Array)
        expect(decrees.size).to eq(20)

        first_decree = decrees.first
        expect(first_decree[:url]).to eq('https://www.genpro.gov.sk//download/uznesenie/2015/03/NR_4401_24_03_2015_a.rtf')
        expect(first_decree[:number]).to eq('NR/4401/24/03/2015')
        expect(first_decree[:effective_on]).to eq(Date.new(2015, 3, 11))
        expect(first_decree[:published_on]).to eq(Date.new(2015, 3, 17))
        expect(first_decree[:file_number]).to eq('1 Pv 645/13/4401')
        expect(first_decree[:resolution].gsub(/[\u00A0\s]+/, ' ')).to eq("Uznesenie prokurátora o osvedčení sa v skúšobnej dobe")
        expect(first_decree[:means_of_resolution]).to eq("podmienečné zastavenie trestného stíhania, osvedčil sa - § 217/1 (§ 308/3) Tr.por.")
        expect(first_decree[:file_type]).to eq('rtf')
      end

      it 'parses page 2100 correctly' do
        html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'decrees', 'page_2100.html'))
        decrees = described_class.parse(html, url: 'https://www.genpro.gov.sk/')

        expect(decrees).to be_an(Array)
        expect(decrees.size).to eq(20)

        decrees.each do |decree|
          expect(decree).to have_key(:url)
          expect(decree).to have_key(:number)
          expect(decree).to have_key(:effective_on)
          expect(decree).to have_key(:published_on)
          expect(decree).to have_key(:file_number)
          expect(decree).to have_key(:resolution)
          expect(decree).to have_key(:means_of_resolution)
          expect(decree).to have_key(:file_type)
          expect(decree[:file_type]).to eq('rtf')
        end
      end
    end

    context 'with pages containing mixed file types' do
      it 'parses page 1950 correctly' do
        html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'decrees', 'page_1950.html'))
        decrees = described_class.parse(html, url: 'https://www.genpro.gov.sk/')

        expect(decrees).to be_an(Array)
        expect(decrees.size).to eq(20)

        rtf_decrees = decrees.select { |d| d[:file_type] == 'rtf' }
        pdf_decrees = decrees.select { |d| d[:file_type] == 'pdf' }

        expect(rtf_decrees.size).to eq(19)
        expect(pdf_decrees.size).to eq(1)
      end

      it 'parses page 2050 correctly' do
        html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'decrees', 'page_2050.html'))
        decrees = described_class.parse(html, url: 'https://www.genpro.gov.sk/')

        expect(decrees).to be_an(Array)
        expect(decrees.size).to eq(20)

        rtf_decrees = decrees.select { |d| d[:file_type] == 'rtf' }
        pdf_decrees = decrees.select { |d| d[:file_type] == 'pdf' }

        expect(rtf_decrees.size).to eq(19)
        expect(pdf_decrees.size).to eq(1)
      end
    end

    context 'validates all parsed fields' do
      let(:html) { File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'decrees', 'page_1.html')) }
      let(:decrees) { described_class.parse(html, url: 'https://www.genpro.gov.sk/') }

      it 'parses URL correctly' do
        decrees.each do |decree|
          expect(decree[:url]).to be_a(String)
          expect(decree[:url]).to start_with('https://www.genpro.gov.sk/')
          expect(decree[:url]).to match(/\.(pdf|rtf)$/)
        end
      end

      it 'parses number correctly' do
        decrees.each do |decree|
          expect(decree[:number]).to be_a(String)
          expect(decree[:number]).to match(%r{^[A-Z]+/\d+/\d+/\d+/\d+$})
        end
      end

      it 'parses effective_on as Date' do
        decrees.each do |decree|
          expect(decree[:effective_on]).to be_a(Date)
        end
      end

      it 'parses published_on as Date' do
        decrees.each do |decree|
          expect(decree[:published_on]).to be_a(Date)
        end
      end

      it 'parses file_number correctly' do
        decrees.each do |decree|
          expect(decree[:file_number]).to be_a(String)
          expect(decree[:file_number]).not_to be_empty
        end
      end

      it 'parses resolution correctly' do
        decrees.each do |decree|
          expect(decree[:resolution]).to be_a(String)
          expect(decree[:resolution]).not_to be_empty
        end
      end

      it 'parses means_of_resolution correctly' do
        decrees.each do |decree|
          expect(decree[:means_of_resolution]).to be_a(String)
          expect(decree[:means_of_resolution]).not_to be_empty
        end
      end

      it 'parses file_type correctly' do
        decrees.each do |decree|
          expect(decree[:file_type]).to be_a(String)
          expect(['pdf', 'rtf']).to include(decree[:file_type])
        end
      end
    end

    context 'with all fixture files' do
      it 'successfully parses all downloaded fixtures' do
        fixtures_dir = Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'decrees')
        fixture_files = Dir.glob(fixtures_dir.join('page_*.html'))

        expect(fixture_files.size).to eq(10)

        fixture_files.each do |file|
          html = File.read(file)
          decrees = described_class.parse(html, url: 'https://www.genpro.gov.sk/')

          expect(decrees).to be_an(Array)
          expect(decrees.size).to be > 0

          decrees.each do |decree|
            expect(decree).to have_key(:url)
            expect(decree).to have_key(:number)
            expect(decree).to have_key(:effective_on)
            expect(decree).to have_key(:published_on)
            expect(decree).to have_key(:file_number)
            expect(decree).to have_key(:resolution)
            expect(decree).to have_key(:means_of_resolution)
            expect(decree).to have_key(:file_type)
          end
        end
      end
    end
  end
end
