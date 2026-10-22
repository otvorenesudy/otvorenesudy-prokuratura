# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::ImportDeclarationsJob do
  let(:url) { 'https://www.genpro.gov.sk/majetkove-priznania/?page=1' }

  before do
    stub_source(url, 'genpro_gov_sk/declaration_listings/page.html')

    { 48_384 => 'Martin-Kovac-OPZH-2024', 48_640 => 'Andrea-Jancova-OPZA-2024', 48_896 => 'Martin-Kovac-KPZA-2024' }
      .each do |id, declaration|
        stub_request(:get, /majetkove-priznania\?.*priznania%5D=#{id}\b/)
          .to_return(body: fixture("genpro_gov_sk/declarations/#{declaration}/data.html").read)
      end
  end

  it 'imports each declaration on the page, by the prosecutor and the office the listing names' do
    described_class.perform_now(url)

    declarations = GenproGovSk::Declaration.all.map { |declaration| declaration.data.values_at('name', 'office', 'year') }

    expect(declarations).to contain_exactly(
      ['Martin Kováč', 'Okresná prokuratúra Žiar nad Hronom', 2024],
      ['Dávid Stašák', 'Okresná prokuratúra Spišská Nová Ves', 2024],
      ['Vlastimil Krokvička', 'Krajská prokuratúra v Trenčíne', 2024]
    )
    expect(GenproGovSk::Declaration.first.data['lists']).to be_present
  end

  it 'leaves the declarations it has already imported as they are' do
    described_class.perform_now(url)

    expect { described_class.perform_now(url) }.not_to(change { GenproGovSk::Declaration.pluck(:id, :updated_at) })
  end
end
