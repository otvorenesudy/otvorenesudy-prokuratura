require 'rails_helper'

RSpec.describe GenproGovSk::Offices::Parser do
  describe '.parse' do
    it 'parses the general office correctly' do
      html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'general.html'))
      data = described_class.parse(html)

      expect(data[:name]).to eq('Generálna prokuratúra Slovenskej republiky')
      expect(data[:type]).to eql(:general)
      expect(data[:address]).to eq('Štúrova 2')
      expect(data[:zipcode]).to eq('812 85')
      expect(data[:city]).to eq('Bratislava 1')
      expect(data[:phone]).to eq('02/208 37 505, 02/595 32 505')
      expect(data[:email]).to eq('GPSR@genpro.gov.sk')
      expect(data[:electronic_registry]).to eq('https://www.slovensko.sk/sk/lokator-sluzieb')
      expect(data[:registry]).to eql(
        {
          phone: '02/208 37 766, 02/595 32 766',
          note:
            'Na základe rozhodnutia generálneho prokurátora Slovenskej republiky pre prijímanie podaní, ktoré sú urobené ústne do zápisnice na Generálnej prokuratúre Slovenskej republiky a na Úrade špeciálnej prokuratúry Generálnej prokuratúry Slovenskej republiky sa v rámci úradných hodín vymedzuje konkrétny čas od 9:00 h do 11:00 h.',
          hours: {
            'pondelok' => '8:00 – 15:00',
            'utorok' => '8:00 – 15:00',
            'streda' => '8:00 – 15:00',
            'štvrtok' => '8:00 – 15:00',
            'piatok' => '8:00 – 15:00'
          }
        }
      )

      expect(data[:employees][0][:name]).to eq('Dr. JUDr. Maroš Žilinka, PhD.')
      expect(data[:employees][0][:position]).to eq('generálny prokurátor Slovenskej republiky')
      expect(data[:employees][0][:phone]).to eq('02/208 37 606, 02/208 37 620')

      expect(data[:employees][1][:name]).to eq('JUDr. Jozef Kandera')
      expect(data[:employees][1][:position]).to eq('prvý námestník generálneho prokurátora Slovenskej republiky')
      expect(data[:employees][1][:phone]).to eq('02/208 37 528')

      expect(data[:employees][2][:name]).to eq('JUDr. Vladimír Javorský, PhD.')
      expect(data[:employees][2][:position]).to eq('riaditeľ trestného odboru')
      expect(data[:employees][2][:phone]).to eq('02/208 37 617')

      expect(data[:employees][-1][:name]).to eq('Mgr. Peter Kuna, PhD.')
      expect(data[:employees][-1][:position]).to eq('manažér kybernetickej bezpečnosti a informačnej bezpečnosti')
      expect(data[:employees][-1][:phone]).to eq('02/208 36 674')

      expect(data[:employees].size).to be >= 40
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
