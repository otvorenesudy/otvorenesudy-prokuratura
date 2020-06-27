require 'rails_helper'

RSpec.describe 'GenproGovSk Offices', type: :feature do
  it 'correctly parses all offices', webmock: :disabled do
    offices = GenproGovSk::Offices.import

    expect(offices.size).to eql(64)
  end
end
