require 'rails_helper'

RSpec.describe GenproGovSk::Criminality::StructureParser do
  describe '.parse' do
    let(:csv_2024_url) do
      'https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2024/12_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv'
    end

    it 'parses 2024 CSV with new metrics and returns no unknown attributes' do
      result =
        FileDownloader.download(URI::Parser.new.escape(csv_2024_url)) do |path|
          content = File.read(path, encoding: 'Windows-1250').force_encoding('UTF-8')
          described_class.parse(content)
        end

      expect(result).to be_an(Array)
      expect(result.first[:unknown]).to be_empty

      first_office = result.first
      expect(first_office[:year]).to eq('2024')
      expect(first_office[:statistics]).to be_an(Array)

      metrics = first_office[:statistics].map { |s| s[:metric] }
      expect(metrics).to include(:prosecuted_legal_entities)
      expect(metrics).to include(:prosecuted_young_boys)
      expect(metrics).to include(:prosecuted_young_girls)
      expect(metrics).to include(:prosecuted_alcohol_abuse)
      expect(metrics).to include(:prosecuted_substance_abuse)
      expect(metrics).to include(:prosecuted_foreigners)
      expect(metrics).to include(:accused_recidivists_all)
    end

    it 'parses all structure CSV files without unknown attributes' do
      urls = %w[
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2023/12_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2024/12_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
      ]

      urls.each do |url|
        result =
          FileDownloader.download(URI::Parser.new.escape(url)) do |path|
            content = File.read(path, encoding: 'Windows-1250').force_encoding('UTF-8')
            described_class.parse(content)
          end

        result.each do |office_result|
          expect(office_result[:unknown]).to be_empty,
          "Unknown attributes found in #{url}: #{office_result[:unknown].join(', ')}"
        end
      end
    end

    it 'does not include empty strings in unknown attributes' do
      url = csv_2024_url

      result =
        FileDownloader.download(URI::Parser.new.escape(url)) do |path|
          content = File.read(path, encoding: 'Windows-1250').force_encoding('UTF-8')
          described_class.parse(content)
        end

      result.each do |office_result|
        expect(office_result[:unknown]).not_to include('')
        expect(office_result[:unknown]).not_to include(nil)
      end
    end
  end

  describe '.normalize_metric' do
    it 'normalizes odstíhaných to stíhaných' do
      result = described_class.normalize_metric('Skladba odstíhaných osôb')
      expect(result).to eq('Skladba stíhaných osôb')
    end

    it 'normalizes multiple spaces' do
      result = described_class.normalize_metric('Skladba    stíhaných  osôb')
      expect(result).to eq('Skladba stíhaných osôb')
    end
  end

  describe '.ignore_title?' do
    it 'ignores titles starting with Za obdobie:' do
      expect(described_class.ignore_title?('Za obdobie: od 01.01.2024 do 31.12.2024')).to be true
    end

    it 'ignores standalone Skladba stíhaných osôb' do
      expect(described_class.ignore_title?('Skladba stíhaných osôb')).to be true
    end

    it 'ignores Počet spáchaných trestných činov' do
      expect(described_class.ignore_title?('Počet spáchaných trestných činov')).to be true
    end

    it 'ignores Skladba trestných činov with hlava' do
      expect(described_class.ignore_title?('Skladba trestných činov 1.hlava')).to be true
    end

    it 'does not ignore valid metrics' do
      expect(described_class.ignore_title?('Skladba stíhaných osôb muži')).to be_falsey
    end
  end
end
