require 'rails_helper'

RSpec.describe 'GenproGovSk Offices', type: :feature do
  it 'correctly parses all offices', webmock: :disabled do
    pending

    offices = GenproGovSk::Offices.import

    expect(offices.size).to eql(63)
  end
end
