# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Prosecutors' do
  describe 'the export of the estate declarations' do
    def declaration(id, name:, year:, **attributes)
      { genpro_gov_sk_declaration_id: id, name:, year:, url: "https://www.genpro.gov.sk/#{id}", **attributes }
    end

    it 'lists every item, income and statement of every declaration, with the prosecutor\'s offices' do
      apartment = { description: 'Byt', acquisition_date: '2015', acquisition_reason: 'kúpa', price: '100 000 €',
                    procurement_price: nil }
      declarations = [
        declaration(1, name: 'JUDr. Ján Novák', year: 2023, lists: [{ category: 'Nehnuteľnosti', items: [apartment] }],
                       incomes: [{ description: 'Plat', value: '50 000 €' }], statements: ['Žiadne'])
      ]
      prosecutor = create(:prosecutor, name: 'JUDr. Ján Novák', declarations:)
      create(:appointment, prosecutor:, office: Office.find_by!(name: 'Okresná prokuratúra Žilina'))
      create(:appointment, prosecutor:, office: Office.find_by!(name: 'Krajská prokuratúra v Žiline'), type: :temporary)

      get export_prosecutors_path

      rows = CSV.parse(response.body)
      offices = ['Okresná prokuratúra Žilina', 'Krajská prokuratúra v Žiline']
      columns = [prosecutor.id.to_s, 'JUDr. Ján Novák', *offices, '2023']

      expect(response.media_type).to eq('text/plain')
      expect(rows.first).to start_with('ID', 'Name', 'Current Office', 'Temporary Office', 'Declaration Year')
      expect(rows.drop(1)).to eq(
        [
          [*columns, 'Nehnuteľnosti', 'Byt', '2015', 'kúpa', '100 000 €', nil],
          [*columns, 'Príjmy', 'Plat', nil, nil, nil, '50 000 €', nil],
          [*columns, 'Vyhlásenia', 'Žiadne', nil, nil, nil, nil, nil]
        ]
      )
    end

    it 'leaves out the offices a prosecutor lacks, the incomes a declaration lacks, and those without a declaration' do
      car = { description: 'Auto', acquisition_date: '2020' }
      declarations = [
        declaration(2, name: 'JUDr. Eva Malá', year: 2024, lists: [{ category: 'Hnuteľné veci', items: [car] }],
                       incomes: nil, statements: [])
      ]
      prosecutor = create(:prosecutor, name: 'JUDr. Eva Malá', declarations:)
      create(:prosecutor, name: 'JUDr. Peter Horváth', declarations: nil)

      get export_prosecutors_path

      expect(CSV.parse(response.body).drop(1))
        .to eq([[prosecutor.id.to_s, 'JUDr. Eva Malá', nil, nil, '2024', 'Hnuteľné veci', 'Auto', '2020', *[nil] * 3]])
    end
  end
end
