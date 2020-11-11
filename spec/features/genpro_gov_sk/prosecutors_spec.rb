require 'rails_helper'

RSpec.describe 'GenproGovSk Prosecutors', type: :feature do
  it 'correctly parses all prosecutors', webmock: :disabled do
    GenproGovSk::Offices.import

    GenproGovSk::Prosecutors.import

    expect(::Prosecutor.count).to eql(967)

    GenproGovSk::Prosecutors::Parser::FIXED_OFFICES_BY_PROSECUTOR_NAME.each do |name, office|
      prosecutor = ::Prosecutor.find_by(name: name)

      expect(prosecutor.offices.pluck(:name)).to eql(['Úrad špeciálnej prokuratúry'])
    end
  end
end
