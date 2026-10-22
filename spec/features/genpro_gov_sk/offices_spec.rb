# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GenproGovSk Offices' do
  let(:expected) { JSON.parse(fixture('genpro_gov_sk/offices/all_offices.json').read) }
  let(:contacts) { %w[name type address zipcode city phone fax email electronic_registry] }
  let(:employee) { %w[name position phone rank] }

  # What the expected data gives of an office: its contacts always, its registry's phone, and its registry's note and
  # hours and its staff where the expected data has them.
  def parts(registry)
    ['phone', ('note' if registry['note']), ('hours' if registry['hours'])].compact
  end

  def imported(office, expected)
    data = office.attributes.slice(*contacts)
    data['registry'] = office.registry.slice(*parts(expected['registry'])) if expected['registry']
    data['employees'] = office.employees.order(:rank).map { |e| e.attributes.slice(*employee) } if expected['employees']
    data
  end

  def wanted(expected)
    data = expected.slice(*contacts)
    data['registry'] = expected['registry'].slice(*parts(expected['registry'])) if expected['registry']
    return data unless expected['employees']

    data.merge('employees' => expected['employees'].sort_by { |e| e['rank'] }.map { |e| e.slice(*employee) })
  end

  it 'imports every office of the recorded pages as expected' do
    GenproGovSk::Offices.import

    # The suite's database holds the seeds' offices too; these are the ones the import read.
    offices = Office.where.not(genpro_gov_sk_office_id: nil).index_by(&:name)
    imports = expected.map { |office| imported(offices[office['name']], office) }

    expect(offices.keys).to match_array(expected.pluck('name'))
    expect(imports).to eq(expected.map { |office| wanted(office) })
  end
end
