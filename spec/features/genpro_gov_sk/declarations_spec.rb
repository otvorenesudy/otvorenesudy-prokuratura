# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GenproGovSk Declarations' do
  describe 'ImportDeclarationsJob' do
    it 'imports the declarations of Maroš Žilinka and gives them to him' do
      url = 'https://www.genpro.gov.sk/majetkove-priznania/?meno=Maro%C5%A1&priezvisko=%C5%BDilinka'
      GenproGovSk::ImportDeclarationsJob.perform_now(url)

      declaration = GenproGovSk::Declaration.find_by("data->>'year' = ?", '2019')

      expect(declaration.data).to include(
        'year' => 2019, 'name' => match(/žilinka/i), 'office' => 'Úrad špeciálnej prokuratúry',
        'lists' => be_present, 'statements' => be_present
      )

      GenproGovSk::Declaration.reconcile!

      expect(Prosecutor.find_by('LOWER(name) LIKE ?', '%žilinka%').declarations.pluck('year')).to include(2019)
    end
  end
end
