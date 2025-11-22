require 'rails_helper'

RSpec.describe 'GenproGovSk Offices', type: :feature do
  it 'correctly parses and imports office from fixture HTML' do
    # Load fixture HTML
    html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'general.html'))
    
    # Parse the data
    data = GenproGovSk::Offices::Parser.parse(html)

    # Verify basic structure
    expect(data[:name]).to eq('Generálna prokuratúra Slovenskej republiky')
    expect(data[:type]).to eq(:general)
    expect(data[:address]).to eq('Štúrova 2')
    expect(data[:city]).to eq('Bratislava 1')
    expect(data[:zipcode]).to eq('812 85')
    expect(data[:phone]).to eq('02/208 37 505, 02/595 32 505')
    expect(data[:fax]).to be_nil
    expect(data[:email]).to eq('GPSR@genpro.gov.sk')
    expect(data[:electronic_registry]).to eq('https://www.slovensko.sk/sk/lokator-sluzieb')
    
    # Verify registry data
    expect(data[:registry]).to be_present
    expect(data[:registry][:note]).to include('Na základe rozhodnutia generálneho prokurátora')
    expect(data[:registry][:phone]).to eq('02/208 37 766, 02/595 32 766')
    expect(data[:registry][:hours][:monday]).to eq('8:00 – 15:00')
    expect(data[:registry][:hours][:tuesday]).to eq('8:00 – 15:00')
    expect(data[:registry][:hours][:wednesday]).to eq('8:00 – 15:00')
    expect(data[:registry][:hours][:thursday]).to eq('8:00 – 15:00')
    expect(data[:registry][:hours][:friday]).to eq('8:00 – 15:00')
    
    # Verify employees list
    expect(data[:employees]).to be_an(Array)
    expect(data[:employees].size).to be > 40
    expect(data[:employees].first[:name]).to eq('Dr. JUDr. Maroš Žilinka, PhD.')
    expect(data[:employees].first[:position]).to eq('generálny prokurátor Slovenskej republiky')
    expect(data[:employees].first[:phone]).to eq('02/208 37 606, 02/208 37 620')
  end
end
