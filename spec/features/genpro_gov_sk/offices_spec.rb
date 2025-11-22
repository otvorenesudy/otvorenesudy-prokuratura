require 'rails_helper'

RSpec.describe 'GenproGovSk Offices', type: :feature do
  it 'correctly fetches all 63 office URLs', webmock: :disabled do
    html = Curl.get('https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/').body_str
    doc = Nokogiri::HTML(html)

    links = doc.css('.tx-tempest-contacts .govuk-table__row td > a')

    expect(links.size).to eq(63)
  end

  it 'correctly imports and validates all 63 offices with all attributes including employees', webmock: :disabled do
    expected_offices = JSON.parse(
      File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'all_offices_expected.json')),
      symbolize_names: true
    )

    # Stub the parser to return expected data for each office
    call_count = 0
    allow(GenproGovSk::Offices::Parser).to receive(:parse) do |html|
      expected_offices[call_count].tap { call_count += 1 }
    end

    # Capture all calls to import_from
    import_calls = []
    allow(GenproGovSk::Office).to receive(:import_from) do |**kwargs|
      import_calls << kwargs
    end

    # Call the actual import method
    GenproGovSk::Offices.import

    # Verify parser was called 63 times
    expect(GenproGovSk::Offices::Parser).to have_received(:parse).exactly(63).times

    # Verify import_from was called 63 times
    expect(GenproGovSk::Office).to have_received(:import_from).exactly(63).times

    # Validate each office's data
    expect(import_calls.size).to eq(63)
    
    import_calls.each_with_index do |call, index|
      actual_data = call[:data]
      expected_office = expected_offices[index]

      # Validate all attributes
      expect(actual_data[:name]).to eq(expected_office[:name]), "Office #{index + 1} (#{expected_office[:name]}) name mismatch"
      expect(actual_data[:type]).to eq(expected_office[:type]), "Office #{index + 1} (#{expected_office[:name]}) type mismatch"
      expect(actual_data[:address]).to eq(expected_office[:address]), "Office #{index + 1} (#{expected_office[:name]}) address mismatch"
      expect(actual_data[:zipcode]).to eq(expected_office[:zipcode]), "Office #{index + 1} (#{expected_office[:name]}) zipcode mismatch"
      expect(actual_data[:city]).to eq(expected_office[:city]), "Office #{index + 1} (#{expected_office[:name]}) city mismatch"
      expect(actual_data[:phone]).to eq(expected_office[:phone]), "Office #{index + 1} (#{expected_office[:name]}) phone mismatch"
      expect(actual_data[:fax]).to eq(expected_office[:fax]), "Office #{index + 1} (#{expected_office[:name]}) fax mismatch"
      expect(actual_data[:email]).to eq(expected_office[:email]), "Office #{index + 1} (#{expected_office[:name]}) email mismatch"
      expect(actual_data[:electronic_registry]).to eq(expected_office[:electronic_registry]), "Office #{index + 1} (#{expected_office[:name]}) electronic_registry mismatch"
      expect(actual_data[:registry][:note]).to eq(expected_office[:registry][:note]), "Office #{index + 1} (#{expected_office[:name]}) registry note mismatch"
      expect(actual_data[:registry][:phone]).to eq(expected_office[:registry][:phone]), "Office #{index + 1} (#{expected_office[:name]}) registry phone mismatch"
      expect(actual_data[:registry][:hours]).to eq(expected_office[:registry][:hours]), "Office #{index + 1} (#{expected_office[:name]}) registry hours mismatch"
      
      # Validate employees list
      expect(actual_data[:employees].size).to eq(expected_office[:employees].size), "Office #{index + 1} (#{expected_office[:name]}) employee count mismatch"
      
      actual_data[:employees].each_with_index do |employee, emp_index|
        expected_employee = expected_office[:employees][emp_index]
        expect(employee[:name]).to eq(expected_employee[:name]), "Office #{index + 1} (#{expected_office[:name]}), Employee #{emp_index + 1} name mismatch"
        expect(employee[:position]).to eq(expected_employee[:position]), "Office #{index + 1} (#{expected_office[:name]}), Employee #{emp_index + 1} position mismatch"
        expect(employee[:phone]).to eq(expected_employee[:phone]), "Office #{index + 1} (#{expected_office[:name]}), Employee #{emp_index + 1} phone mismatch"
        expect(employee[:rank]).to eq(expected_employee[:rank]), "Office #{index + 1} (#{expected_office[:name]}), Employee #{emp_index + 1} rank mismatch"
      end
    end
  end
end
