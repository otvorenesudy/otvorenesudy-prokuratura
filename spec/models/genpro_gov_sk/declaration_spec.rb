# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Declaration do
  describe '.reconcile!' do
    let(:zilina) { Office.find_by!(name: 'Okresná prokuratúra Žilina') }

    def prosecutor(office)
      create(:prosecutor, name: 'JUDr. Ján Novák', name_parts: { first: 'Ján', last: 'Novák' }).tap do |prosecutor|
        create(:appointment, prosecutor:, office:)
      end
    end

    def declaration(name:, office:, year: 2023)
      data = { name:, office:, year:, url: "https://www.genpro.gov.sk/majetkove-priznania/#{year}",
               lists: [{ category: 'Nehnuteľnosti', items: [{ description: "Byt #{year}" }] }], incomes: nil,
               statements: ['Vyhlásenie'] }

      described_class.import_from(data:, file: "#{name} #{year}")
    end

    it 'gives a prosecutor of the list the declaration, and an appointment at its office in its year' do
      novak = prosecutor(zilina)
      declaration(name: 'Ján Novák', office: zilina.name)

      described_class.reconcile!

      expect(novak.reload.declarations.map { |data| data.values_at('year', 'office') }).to eq([[2023, zilina.name]])
      expect(novak.all_appointments.past.map { |appointment| [appointment.office, appointment.started_at.year] })
        .to eq([[zilina, 2023]])
    end

    it 'adds a prosecutor it does not know, at a place outside the offices' do
      declaration(name: 'JUDr. Eva Malá', office: 'Úrad Európskej prokuratúry')

      described_class.reconcile!

      prosecutor = Prosecutor.find_by!(name: 'JUDr. Eva Malá')

      expect(prosecutor.name_parts).to include('first' => 'Eva', 'last' => 'Malá', 'prefix' => 'JUDr.')
      expect(prosecutor.all_appointments.map(&:place)).to eq(['Úrad Európskej prokuratúry'])
    end

    it 'adds no appointment for a declaration that names no office' do
      novak = prosecutor(zilina)
      declaration(name: 'Ján Novák', office: nil)

      described_class.reconcile!

      expect(novak.reload.declarations.pluck('year')).to eq([2023])
      expect(novak.all_appointments.past).to be_empty
    end

    it 'keeps one appointment a year at the declaration\'s office, however often it reconciles' do
      novak = prosecutor(zilina)
      declaration(name: 'Ján Novák', office: zilina.name)

      2.times { described_class.reconcile! }

      expect(novak.all_appointments.past.map { |appointment| [appointment.office, appointment.started_at.year] })
        .to eq([[zilina, 2023]])
    end

    it 'keeps one declaration a year' do
      novak = prosecutor(zilina)
      declaration(name: 'Ján Novák', office: zilina.name, year: 2022)
      declaration(name: 'Ján Novák', office: zilina.name, year: 2023)

      2.times { described_class.reconcile! }

      expect(novak.reload.declarations.pluck('year')).to contain_exactly(2022, 2023)
    end
  end
end
