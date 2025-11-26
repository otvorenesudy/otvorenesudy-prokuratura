require 'rails_helper'

RSpec.describe 'GenproGovSk Declarations', type: :feature, webmock: :disabled, geocoder: true do
  describe 'ImportDeclarationsJob' do
    it 'imports declarations for Maroš Žilinka from live website' do
      create(:office, name: 'Úrad špeciálnej prokuratúry')
      create(:office, name: 'Generálna prokuratúra Slovenskej republiky')

      url = 'https://www.genpro.gov.sk/majetkove-priznania/?meno=Maro%C5%A1&priezvisko=%C5%BDilinka'
      GenproGovSk::ImportDeclarationsJob.perform_now(url)

      expect(GenproGovSk::Declaration.count).to be > 0

      declaration = GenproGovSk::Declaration.first
      expect(declaration.data).to have_key('year')
      expect(declaration.data).to have_key('lists')
      expect(declaration.data).to have_key('statements')
      expect(declaration.data).to have_key('name')
      expect(declaration.data).to have_key('office')

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
