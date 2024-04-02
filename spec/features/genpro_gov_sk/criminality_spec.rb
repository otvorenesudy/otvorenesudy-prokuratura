require 'rails_helper'

RSpec.describe 'GenproGovSk::Criminality', type: :feature do
  it 'correctly imports and parses data', webmock: :disabled do
    skip

    GenproGovSk::Offices.import
    GenproGovSk::Criminality.import

    validations = [
      { year: 2019, office: 'Okresná prokuratúra Pezinok', metric: :accused_men, count: 249 },
      { year: 2019, office: 'Krajská prokuratúra Trnava', metric: :reconciliation_approval, count: 21 },
      { year: 2019, office: 'Okresná prokuratúra Trenčín', metric: :valid_court_decision_all, count: 774 }
    ]

    validations.each do |attributes|
      office = Office.find_by(name: attributes.delete(:office))

      expect(Statistic.find_by(attributes.merge(office_id: office.id))).to be_present
    end
  end
end
