# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReconcileDecreeJob do
  def reconcile(text)
    create(:decree, text:).tap { |decree| described_class.perform_now(decree) }.reload
  end

  it 'finds the office however the decree spells it' do
    {
      'Uznesenie Krajskej prokuratúry v Bratislave o zastavení' => 'Krajská prokuratúra v Bratislave',
      'Okresná prokuratúra Košice-okolie, Štúrova 29' => 'Okresná prokuratúra Košice - okolie',
      'Ú r a d   š p e c i á l n e j   p r o k u r a t ú r y' => 'Úrad špeciálnej prokuratúry'
    }.each do |preamble, office|
      expect(reconcile("#{preamble} rozhodol takto.").office.name).to eq(office)
    end
  end

  it 'leaves the office, the prosecutor and the paragraph out when the decree names none it knows' do
    decree = reconcile('Rozhodnutie bez hlavičky. Podpísaný neznámy.')

    expect(decree).to have_attributes(office: nil, prosecutor: nil, paragraph: nil)
  end

  it 'finds a prosecutor who worked at the office before, signed in any order of the names' do
    zilina = Office.find_by!(name: 'Okresná prokuratúra Žilina')
    prosecutor = create(:prosecutor, name_parts: { first: 'Eva', middle: 'Mária', last: 'Malá' })
    create(:appointment, prosecutor:, office: zilina, ended_at: 1.year.ago)

    decree = reconcile("Okresná prokuratúra Žilina rozhodla takto: zastavuje sa. #{'x' * 120} Malá Eva Mária, prokurátorka")

    expect(decree.prosecutor).to eq(prosecutor)
  end

  it 'finds a paragraph the decree names without its section' do
    decree = reconcile('Prečin: krádeže podľa § 212.')

    expect(decree.paragraph.value).to eq('§ 212 [new]')
    expect(decree.paragraph_section).to be_nil
  end

  it 'leaves out a paragraph the Criminal Code does not have' do
    decree = reconcile('Trestný čin: podľa § 999 ods. 1 Trestného zákona sa zastavuje.')

    expect(decree.paragraph).to be_nil
  end

  it 'finds a paragraph of the Criminal Code of 1961' do
    decree = reconcile('Trestný čin: prijímania úplatku podľa § 160 ods. 1 Trestného zákona č. 140/1961 Zb. sa zastavuje.')

    expect(decree.paragraph.value).to eq('§ 160 [old]')
    expect(decree.paragraph_section).to eq('ods. 1')
  end
end
