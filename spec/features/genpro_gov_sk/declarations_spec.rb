require 'rails_helper'

RSpec.describe 'GenproGovSk Declarations', type: :feature, webmock: :disabled, geocoder: true do
  describe 'ImportDeclarationsJob' do
    it 'imports declarations for Maroš Žilinka from live website' do
      create(:office, name: 'Úrad špeciálnej prokuratúry')
      create(:office, name: 'Generálna prokuratúra Slovenskej republiky')

      url = 'https://www.genpro.gov.sk/majetkove-priznania/?meno=Maro%C5%A1&priezvisko=%C5%BDilinka'
      GenproGovSk::ImportDeclarationsJob.perform_now(url)

      expect(GenproGovSk::Declaration.count).to be > 0

      declaration = GenproGovSk::Declaration.find_by("data->>'year' = ?", '2019')
      expect(declaration.data['year']).to eq(2019)
      expect(declaration.data['name'].downcase).to include('žilinka')
      expect(declaration.data['office']).to eq('Úrad špeciálnej prokuratúry')
      expect(declaration.data['lists']).to be_present
      expect(declaration.data['statements']).to be_present

      GenproGovSk::Declaration.reconcile!

      prosecutor = Prosecutor.find_by('LOWER(name) LIKE ?', '%žilinka%')
      expect(prosecutor).to be_present

      expect(prosecutor.declarations).to be_present
      expect(prosecutor.declarations.length).to be > 0

      declaration_years = prosecutor.declarations.map { |d| d['year'] }
      expect(declaration_years).to include(2019)
    end
  end
end
