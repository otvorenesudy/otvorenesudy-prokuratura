require 'rails_helper'

RSpec.describe GenproGovSk::Offices::Parser do
  describe '.parse' do
    it 'parses the main office correctly' do
      html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'main.html'))
      data = described_class.parse(html)

      expect(data[:name]).to eq('Generálna prokuratúra Slovenskej republiky')
      expect(data[:address]).to eq(['Generálna prokuratúra Slovenskej republiky', 'Štúrova 2', '812 85 Bratislava 1'])
      expect(data[:phone]).to eq('02/208 37 505, 595 32 505')
      expect(data[:email]).to eq('GPSR@genpro.gov.sk')
      expect(data[:electronic_registry]).to eq('https://www.slovensko.sk/sk/lokator-sluzieb')
      expect(data[:registry]).to eql(
        {
          phone: '02/208 37 768, 595 32 768',
          hours: {
            monday: %w[8:00 15:00],
            tuesday: %w[8:00 15:00],
            wednesday: %w[8:00 15:00],
            thursday: %w[8:00 15:00],
            friday: %w[8:00 15:00]
          }
        }
      )

      expect(data[:employees][0][:name]).to eq('JUDr. Jaromír Čižnár')
      expect(data[:employees][0][:position]).to eq('generálny prokurátor Slovenskej republiky')
      expect(data[:employees][0][:phone]).to eq('02/208 37 621')

      expect(data[:employees][1][:name]).to eq('JUDr. Viera Kováčiková')
      expect(data[:employees][1][:position]).to eq('prvá námestníčka generálneho prokurátora Slovenskej republiky')
      expect(data[:employees][1][:phone]).to eq('02/208 37 527')

      expect(data[:employees][2][:name]).to eq('JUDr. Radovan Kajaba, PhD.')
      expect(data[:employees][2][:position]).to eq('riaditeľ trestného odboru')
      expect(data[:employees][2][:phone]).to eq('02/208 37 566')

      expect(data[:employees][-1][:name]).to eq('Ing. Daniel König, PhD.')
      expect(data[:employees][-1][:position]).to eq('vedúci referátu vnútorného auditu')
      expect(data[:employees][-1][:phone]).to eq('02/208 37 222')

      expect(data[:employees].size).to eql(48)
    end
  end
end
