require 'rails_helper'

RSpec.describe 'GenproGovSk Offices', type: :feature do
  it 'correctly fetches all 63 office URLs', webmock: :disabled do
    html = Curl.get('https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/').body_str
    doc = Nokogiri::HTML(html)

    links = doc.css('.tx-tempest-contacts .govuk-table__row td > a')

    expect(links.size).to eq(63)
  end

  it 'correctly parses data from all offices', webmock: :disabled do
    html = Curl.get('https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/').body_str
    doc = Nokogiri::HTML(html)

    links = doc.css('.tx-tempest-contacts .govuk-table__row td > a').map { |e| "https://www.genpro.gov.sk#{e['href']}" }

    expect(links.size).to eq(63)

    offices_data = links.map do |link|
      office_html = Curl.get(link).body_str
      GenproGovSk::Offices::Parser.parse(office_html)
    end

    expect(offices_data.size).to eq(63)

    offices_with_employees = offices_data.select { |o| o[:employees]&.any? }
    expect(offices_with_employees.size).to be > 50

    office_types = offices_data.map { |o| o[:type] }.uniq
    expect(office_types).to include(:general, :regional, :district)

    offices_data.each do |data|
      expect(data[:name]).to be_present, "Office name should be present"
      expect(data[:type]).to be_in([:general, :regional, :district, :specialized]), "Office type should be valid"
      expect(data[:address]).to be_present, "Address should be present for #{data[:name]}"
      expect(data[:zipcode]).to be_present, "Zipcode should be present for #{data[:name]}"
      expect(data[:city]).to be_present, "City should be present for #{data[:name]}"
      expect(data[:phone]).to be_present, "Phone should be present for #{data[:name]}"
      expect(data[:email]).to be_present, "Email should be present for #{data[:name]}"
      expect(data[:registry]).to be_present, "Registry should be present for #{data[:name]}"
      expect(data[:registry][:hours]).to be_present, "Registry hours should be present for #{data[:name]}"
      expect(data[:registry][:hours]).to have_key('pondelok'), "Registry hours should have pondelok for #{data[:name]}"
      expect(data[:registry][:hours]).to have_key('piatok'), "Registry hours should have piatok for #{data[:name]}"
    end
  end
end
