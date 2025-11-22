require 'rails_helper'

RSpec.describe GenproGovSk::Offices::Parser do
  describe '.parse' do
    it 'parses the general office correctly' do
      html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'general.html'))
      expected_json = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'general.json')), symbolize_names: true)
      
      data = described_class.parse(html)

      expect(data[:name]).to eq(expected_json[:name])
      expect(data[:type]).to eq(expected_json[:type])
      expect(data[:address]).to eq(expected_json[:address])
      expect(data[:zipcode]).to eq(expected_json[:zipcode])
      expect(data[:city]).to eq(expected_json[:city])
      expect(data[:phone]).to eq(expected_json[:phone])
      expect(data[:email]).to eq(expected_json[:email])
      expect(data[:electronic_registry]).to eq(expected_json[:electronic_registry])
      expect(data[:registry][:phone]).to eq(expected_json[:registry][:phone])
      expect(data[:registry][:note]).to eq(expected_json[:registry][:note])
      expect(data[:registry][:hours]).to eq(expected_json[:registry][:hours])

      expect(data[:employees][0][:name]).to eq(expected_json[:employees][0][:name])
      expect(data[:employees][0][:position]).to eq(expected_json[:employees][0][:position])
      expect(data[:employees][0][:phone]).to eq(expected_json[:employees][0][:phone])

      expect(data[:employees][1][:name]).to eq(expected_json[:employees][1][:name])
      expect(data[:employees][1][:position]).to eq(expected_json[:employees][1][:position])
      expect(data[:employees][1][:phone]).to eq(expected_json[:employees][1][:phone])

      expect(data[:employees][2][:name]).to eq(expected_json[:employees][2][:name])
      expect(data[:employees][2][:position]).to eq(expected_json[:employees][2][:position])
      expect(data[:employees][2][:phone]).to eq(expected_json[:employees][2][:phone])

      expect(data[:employees][-1][:name]).to eq(expected_json[:employees][-1][:name])
      expect(data[:employees][-1][:position]).to eq(expected_json[:employees][-1][:position])
      expect(data[:employees][-1][:phone]).to eq(expected_json[:employees][-1][:phone])

      expect(data[:employees].size).to be > 0
    end

    it 'parses a regional office (Bratislava) correctly' do
      html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'krajsk_prokuratra_v_bratislave.html'))
      expected_json = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'krajsk_prokuratra_v_bratislave.json')), symbolize_names: true)
      
      data = described_class.parse(html)

      expect(data[:name]).to eq(expected_json[:name])
      expect(data[:type]).to eq(expected_json[:type])
      expect(data[:address]).to eq(expected_json[:address])
      expect(data[:zipcode]).to eq(expected_json[:zipcode])
      expect(data[:city]).to eq(expected_json[:city])
      expect(data[:phone]).to eq(expected_json[:phone])
      expect(data[:email]).to eq(expected_json[:email])
      expect(data[:registry][:hours]).to have_key(:monday)
      expect(data[:employees].size).to be > 0
    end

    it 'parses a regional office (Košice) correctly' do
      html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'krajsk_prokuratra_v_koiciach.html'))
      expected_json = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'krajsk_prokuratra_v_koiciach.json')), symbolize_names: true)
      
      data = described_class.parse(html)

      expect(data[:name]).to eq(expected_json[:name])
      expect(data[:type]).to eq(expected_json[:type])
      expect(data[:address]).to eq(expected_json[:address])
      expect(data[:zipcode]).to eq(expected_json[:zipcode])
      expect(data[:city]).to eq(expected_json[:city])
      expect(data[:employees].size).to be > 0
    end

    it 'parses a district office (Banská Bystrica) correctly' do
      html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'okresn_prokuratra_bansk_bystrica.html'))
      expected_json = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'okresn_prokuratra_bansk_bystrica.json')), symbolize_names: true)
      
      data = described_class.parse(html)

      expect(data[:name]).to eq(expected_json[:name])
      expect(data[:type]).to eq(expected_json[:type])
      expect(data[:address]).to eq(expected_json[:address])
      expect(data[:zipcode]).to eq(expected_json[:zipcode])
      expect(data[:city]).to eq(expected_json[:city])
      expect(data[:employees].size).to be > 0
    end

    it 'parses a district office (Košice I) correctly' do
      html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'okresn_prokuratra_koice_i.html'))
      expected_json = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'okresn_prokuratra_koice_i.json')), symbolize_names: true)
      
      data = described_class.parse(html)

      expect(data[:name]).to eq(expected_json[:name])
      expect(data[:type]).to eq(expected_json[:type])
      expect(data[:address]).to eq(expected_json[:address])
      expect(data[:zipcode]).to eq(expected_json[:zipcode])
      expect(data[:city]).to eq(expected_json[:city])
      expect(data[:employees].size).to be > 0
    end

    it 'parses a district office (Trnava) correctly' do
      html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'okresn_prokuratra_trnava.html'))
      expected_json = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'okresn_prokuratra_trnava.json')), symbolize_names: true)
      
      data = described_class.parse(html)

      expect(data[:name]).to eq(expected_json[:name])
      expect(data[:type]).to eq(expected_json[:type])
      expect(data[:address]).to eq(expected_json[:address])
      expect(data[:zipcode]).to eq(expected_json[:zipcode])
      expect(data[:city]).to eq(expected_json[:city])
      expect(data[:employees].size).to be > 0
    end
  end

  context 'with coupled people names and positions' do
    it 'correctly parses names and positions of prosecutors' do
      html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'bratislava.html'))
      data = described_class.parse(html)

      expect(data[:name]).to eq('Okresná prokuratúra Bratislava I')
      expect(data[:type]).to eql(:district)

      expect(data[:employees][0][:name]).to eq('JUDr. Katarína Kuljačková')
      expect(data[:employees][0][:position]).to eq('okresná prokurátorka')
      expect(data[:employees][0][:phone]).to eq('02/208 36 611')

      expect(data[:employees][1][:name]).to eq('JUDr. Hana Štaffenová')
      expect(data[:employees][1][:position]).to eq('námestníčka okresnej prokurátorky')
      expect(data[:employees][1][:phone]).to eq('02/208 36 611')

      expect(data[:employees][2][:name]).to eq('JUDr. Norbert Fecko')
      expect(data[:employees][2][:position]).to eq('námestník okresnej prokurátorky')
      expect(data[:employees][2][:phone]).to eq('02/208 36 611')
    end
  end
end
