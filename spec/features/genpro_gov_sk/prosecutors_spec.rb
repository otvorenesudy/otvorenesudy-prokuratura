require 'rails_helper'

RSpec.describe 'GenproGovSk Prosecutors', type: :feature do
  it 'correctly parses all prosecutors', webmock: :disabled do
    GenproGovSk::Offices.import

    prosecutors = GenproGovSk::Prosecutors.import

    expect(prosecutors.size).to eql(967)
  end
end
