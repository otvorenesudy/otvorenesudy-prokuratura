require 'rails_helper'

RSpec.describe 'GenproGovSk Prosecutors', type: :feature do
  it 'correctly parses all prosecutors', webmock: :disabled do
    GenproGovSk::Offices.import

    GenproGovSk::Prosecutors.import

    expect(::Prosecutor.count).to eql(967)
  end
end
