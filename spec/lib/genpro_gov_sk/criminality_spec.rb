# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Criminality do
  describe '.import' do
    let(:url) { 'https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2024/12_Struktura.csv' }
    let(:paragraphs) do
      Rails.root.join('data/genpro_gov_sk/criminality/paragraphs/2019_12_Z1002_1100_TZ_od_2006_*.xlsx').to_s
    end
    let(:general) { Office.find_by!(name: 'Generálna prokuratúra Slovenskej republiky') }
    let(:bratislava) { Office.find_by!(name: 'Krajská prokuratúra v Bratislave') }

    def count(office, year, metric, paragraph = nil)
      Statistic.find_by(office:, year:, metric:, paragraph:)&.count
    end

    it 'imports the offices\' yearly structures and their counts by paragraph' do
      stub_source(url, 'genpro_gov_sk/criminality/structure-2024.csv')

      described_class.import(structure_urls: [url], paragraph_paths: paragraphs)

      expect(count(general, 2024, 'accused_all')).to eq(250)
      expect(count(bratislava, 2024, 'accused_all')).to eq(2920)
      expect(count(general, 2024, 'accused_recidivists_all')).to eq(5)
      expect(count(bratislava, 2019, 'accused_all', '§ 212 [new]')).to eq(1)
    end

    it 'refuses a structure with a metric it does not know' do
      text = fixture('genpro_gov_sk/criminality/structure-2024.csv').read(encoding: 'Windows-1250')
      unknown = text.sub('Počet obžalovaných osôb', 'Počet neznámych osôb').encode('Windows-1250')
      stub_request(:get, url).to_return(body: unknown)

      expect { described_class.import(structure_urls: [url], paragraph_paths: paragraphs) }
        .to raise_error(RuntimeError, /Unknown attributes: \n- Počet neznámych osôb/)
      expect(Statistic.count).to eq(0)
    end
  end
end
