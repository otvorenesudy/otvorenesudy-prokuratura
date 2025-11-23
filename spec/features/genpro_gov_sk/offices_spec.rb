require 'rails_helper'

RSpec.describe 'GenproGovSk Offices', type: :feature do
  it 'imports all offices from live website and validates against expected data' do
    # Load expected data
    expected_offices = JSON.parse(
      File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'all_offices.json')),
      symbolize_names: true
    )

    # Run the actual import (makes live HTTP requests)
    GenproGovSk::Offices.import

    # Fetch all imported offices from database
    imported_offices = ::Office.all.order(:name)

    # Validate count
    expect(imported_offices.count).to eq(expected_offices.count),
      "Expected #{expected_offices.count} offices, but got #{imported_offices.count}"

    # Validate each office
    expected_offices.each_with_index do |expected, index|
      office = imported_offices.find { |o| o.name == expected[:name] }

      expect(office).to be_present,
        "Office '#{expected[:name]}' not found in imported data"

      # Validate basic attributes
      expect(office.name).to eq(expected[:name]),
        "Office '#{expected[:name]}': name mismatch"
      expect(office.type.to_sym).to eq(expected[:type]),
        "Office '#{expected[:name]}': type mismatch (expected: #{expected[:type]}, got: #{office.type})"
      expect(office.address).to eq(expected[:address]),
        "Office '#{expected[:name]}': address mismatch (expected: #{expected[:address]}, got: #{office.address})"
      expect(office.zipcode).to eq(expected[:zipcode]),
        "Office '#{expected[:name]}': zipcode mismatch (expected: #{expected[:zipcode]}, got: #{office.zipcode})"
      expect(office.city).to eq(expected[:city]),
        "Office '#{expected[:name]}': city mismatch (expected: #{expected[:city]}, got: #{office.city})"
      expect(office.phone).to eq(expected[:phone]),
        "Office '#{expected[:name]}': phone mismatch (expected: #{expected[:phone]}, got: #{office.phone})"
      expect(office.fax).to eq(expected[:fax]),
        "Office '#{expected[:name]}': fax mismatch (expected: #{expected[:fax]}, got: #{office.fax})"
      expect(office.email).to eq(expected[:email]),
        "Office '#{expected[:name]}': email mismatch (expected: #{expected[:email]}, got: #{office.email})"
      expect(office.electronic_registry).to eq(expected[:electronic_registry]),
        "Office '#{expected[:name]}': electronic_registry mismatch (expected: #{expected[:electronic_registry]}, got: #{office.electronic_registry})"

      # Validate registry hours if present
      if expected[:registry]
        expect(office.registry).to be_present,
          "Office '#{expected[:name]}': registry data missing"

        expect(office.registry['note']).to eq(expected[:registry][:note]),
          "Office '#{expected[:name]}': registry note mismatch" if expected[:registry][:note]

        expect(office.registry['phone']).to eq(expected[:registry][:phone]),
          "Office '#{expected[:name]}': registry phone mismatch (expected: #{expected[:registry][:phone]}, got: #{office.registry['phone']})"

        if expected[:registry][:hours]
          [:monday, :tuesday, :wednesday, :thursday, :friday].each do |day|
            expect(office.registry['hours'][day.to_s]).to eq(expected[:registry][:hours][day]),
              "Office '#{expected[:name]}': registry hours for #{day} mismatch (expected: #{expected[:registry][:hours][day]}, got: #{office.registry['hours'][day.to_s]})"
          end
        end
      end

      # Validate employees
      if expected[:employees]
        expect(office.employees.count).to eq(expected[:employees].count),
          "Office '#{expected[:name]}': expected #{expected[:employees].count} employees, but got #{office.employees.count}"

        expected[:employees].each_with_index do |expected_employee, emp_index|
          employee = office.employees[emp_index]

          expect(employee.name).to eq(expected_employee[:name]),
            "Office '#{expected[:name]}': employee ##{emp_index + 1} name mismatch (expected: #{expected_employee[:name]}, got: #{employee.name})"
          expect(employee.position).to eq(expected_employee[:position]),
            "Office '#{expected[:name]}': employee ##{emp_index + 1} position mismatch (expected: #{expected_employee[:position]}, got: #{employee.position})"
          expect(employee.phone).to eq(expected_employee[:phone]),
            "Office '#{expected[:name]}': employee ##{emp_index + 1} phone mismatch (expected: #{expected_employee[:phone]}, got: #{employee.phone})"
          expect(employee.rank).to eq(expected_employee[:rank]),
            "Office '#{expected[:name]}': employee ##{emp_index + 1} rank mismatch (expected: #{expected_employee[:rank]}, got: #{employee.rank})"
        end
      end
    end
  end
end
