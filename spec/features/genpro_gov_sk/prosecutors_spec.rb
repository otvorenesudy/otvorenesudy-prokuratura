require 'rails_helper'

RSpec.describe 'GenproGovSk Prosecutors' do
  it 'correctly parses all prosecutors', vcr: :disabled do
    prosecutors = GenproGovSk::Prosecutors.all

    expect(prosecutors.size).to eql(967)
    expect(prosecutors.sort_by { |e| e[:id] }).to eql(
      JSON.parse(File.read(Rails.root.join('spec/fixtures/genpro_gov_sk/prosecutors.json')), symbolize_names: true)
        .sort_by { |e| e[:id] }
    )
  end
end
