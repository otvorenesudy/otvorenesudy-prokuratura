require 'rails_helper'

RSpec.describe 'GenproGovSk Offices', type: :feature do
  it 'correctly imports and validates all 63 offices with all attributes including employees', webmock: :disabled do
    expected_offices = JSON.parse(
      File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'all_offices_expected.json')),
      symbolize_names: true
    )

    # Call the actual import method without stubbing
    GenproGovSk::Offices.import

    # Fetch all offices from database
    offices = GenproGovSk::Office.order(:id).to_a

    # Verify we have 63 offices
    expect(offices.size).to eq(63)

    # Validate each office's data from the database
    offices.each_with_index do |office, index|
      expected_office = expected_offices[index]

      # Validate all attributes
      expect(office.name).to eq(expected_office[:name]), "Office #{index + 1} (#{expected_office[:name]}) name mismatch"
      expect(office.office_type).to eq(expected_office[:type].to_s), "Office #{index + 1} (#{expected_office[:name]}) type mismatch"
      expect(office.address).to eq(expected_office[:address]), "Office #{index + 1} (#{expected_office[:name]}) address mismatch"
      expect(office.zipcode).to eq(expected_office[:zipcode]), "Office #{index + 1} (#{expected_office[:name]}) zipcode mismatch"
      expect(office.city).to eq(expected_office[:city]), "Office #{index + 1} (#{expected_office[:name]}) city mismatch"
      expect(office.phone).to eq(expected_office[:phone]), "Office #{index + 1} (#{expected_office[:name]}) phone mismatch"
      expect(office.fax).to eq(expected_office[:fax]), "Office #{index + 1} (#{expected_office[:name]}) fax mismatch"
      expect(office.email).to eq(expected_office[:email]), "Office #{index + 1} (#{expected_office[:name]}) email mismatch"
      expect(office.electronic_registry).to eq(expected_office[:electronic_registry]), "Office #{index + 1} (#{expected_office[:name]}) electronic_registry mismatch"

      # Validate registry data
      expect(office.registry_note).to eq(expected_office[:registry][:note]), "Office #{index + 1} (#{expected_office[:name]}) registry note mismatch"
      expect(office.registry_phone).to eq(expected_office[:registry][:phone]), "Office #{index + 1} (#{expected_office[:name]}) registry phone mismatch"

      # Validate registry hours
      expected_hours = expected_office[:registry][:hours]
      if expected_hours
        expect(office.registry_hours_monday).to eq(expected_hours[:monday]), "Office #{index + 1} (#{expected_office[:name]}) monday hours mismatch"
        expect(office.registry_hours_tuesday).to eq(expected_hours[:tuesday]), "Office #{index + 1} (#{expected_office[:name]}) tuesday hours mismatch"
        expect(office.registry_hours_wednesday).to eq(expected_hours[:wednesday]), "Office #{index + 1} (#{expected_office[:name]}) wednesday hours mismatch"
        expect(office.registry_hours_thursday).to eq(expected_hours[:thursday]), "Office #{index + 1} (#{expected_office[:name]}) thursday hours mismatch"
        expect(office.registry_hours_friday).to eq(expected_hours[:friday]), "Office #{index + 1} (#{expected_office[:name]}) friday hours mismatch"
      end

      # Validate employees list
      employees = office.prosecutors.order(:position).to_a
      expect(employees.size).to eq(expected_office[:employees].size), "Office #{index + 1} (#{expected_office[:name]}) employee count mismatch"

      employees.each_with_index do |employee, emp_index|
        expected_employee = expected_office[:employees][emp_index]
        expect(employee.name).to eq(expected_employee[:name]), "Office #{index + 1} (#{expected_office[:name]}), Employee #{emp_index + 1} name mismatch"
        expect(employee.position).to eq(expected_employee[:position]), "Office #{index + 1} (#{expected_office[:name]}), Employee #{emp_index + 1} position mismatch"
        expect(employee.phone).to eq(expected_employee[:phone]), "Office #{index + 1} (#{expected_office[:name]}), Employee #{emp_index + 1} phone mismatch"
      end
    end
  end
end
