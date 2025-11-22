require 'rails_helper'

RSpec.describe 'GenproGovSk Offices', type: :feature do
  it 'correctly imports and validates all 63 offices with all attributes including employees', webmock: :disabled do
    expected_offices =
      JSON.parse(
        File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'all_offices_expected.json')),
        symbolize_names: true
      )

    # Call the actual import method without stubbing
    GenproGovSk::Offices.import

    # Fetch all offices from database
    offices = Office.order(:id).to_a

    # Verify we have 63 offices
    expect(offices.size).to eq(63)

    # Validate each office's data from the database
    offices.each_with_index do |office, index|
      expected_office = expected_offices[index]

      # Validate all attributes
      expect(office.name).to eq(expected_office[:name])
      expect(office.type).to eq(expected_office[:type].to_s)
      expect(office.address).to eq(expected_office[:address])
      expect(office.zipcode).to eq(expected_office[:zipcode])
      expect(office.city).to eq(expected_office[:city])
      expect(office.phone).to eq(expected_office[:phone])
      expect(office.fax).to eq(expected_office[:fax])
      expect(office.email).to eq(expected_office[:email])
      expect(office.electronic_registry).to eq(expected_office[:electronic_registry])

      # Validate registry data
      expect(office.registry['note']).to eq(expected_office[:registry][:note])
      expect(office.registry['phone']).to eq(expected_office[:registry][:phone])

      # Validate registry hours
      expected_hours = expected_office[:registry][:hours]

      if expected_hours
        expect(office.registry['hours']['monday']).to eq(expected_hours[:monday])
        expect(office.registry['hours']['tuesday']).to eq(expected_hours[:tuesday])
        expect(office.registry['hours']['wednesday']).to eq(expected_hours[:wednesday])
        expect(office.registry['hours']['thursday']).to eq(expected_hours[:thursday])
        expect(office.registry['hours']['friday']).to eq(expected_hours[:friday])
      end

      # Validate employees list
      employees = office.employees.order(:position).to_a

      expect(employees.size).to eq(expected_office[:employees].size)

      employees.each do |employee|
        expected_employee = expected_office[:employees].find { |e| e[:position] == employee.position }

        expect(employee.name).to eq(expected_employee[:name])
        expect(employee.position).to eq(expected_employee[:position])
        expect(employee.phone).to eq(expected_employee[:phone])
      end
    end
  end
end
