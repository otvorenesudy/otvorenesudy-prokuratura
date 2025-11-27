require 'rails_helper'

RSpec.describe 'GenproGovSk Prosecutors', type: :feature do
  it 'correctly parses all prosecutors', webmock: :disabled do
    GenproGovSk::Offices.import
    GenproGovSk::Prosecutors.import

    expected_prosecutors =
      JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'prosecutors', 'all_prosecutors.json')))

    expect(::Prosecutor.count).to eq(expected_prosecutors.size)

    prosecutor = Prosecutor.find_by(name: 'Mgr. Martin Draľ')
    expect(prosecutor.name).to eq('Mgr. Martin Draľ')
    expect(prosecutor.name_parts).to eq(
      {
        'last' => 'Draľ',
        'role' => nil,
        'first' => 'Martin',
        'flags' => [],
        'middle' => nil,
        'prefix' => 'Mgr.',
        'suffix' => nil,
        'addition' => nil,
        'unprocessed' => 'Draľ Martin, Mgr.'
      }
    )
    expect(prosecutor.offices.map(&:name)).to eq(['Krajská prokuratúra v Košiciach'])

    prosecutor = Prosecutor.find_by(name: 'JUDr. Mgr. Svetlana Žilková Močková')
    expect(prosecutor.name).to eq('JUDr. Mgr. Svetlana Žilková Močková')
    expect(prosecutor.name_parts).to eq(
      {
        'last' => 'Močková',
        'role' => nil,
        'first' => 'Svetlana',
        'flags' => [],
        'middle' => 'Žilková',
        'prefix' => 'JUDr. Mgr.',
        'suffix' => nil,
        'addition' => nil,
        'unprocessed' => 'Žilková Močková Svetlana, JUDr. Mgr.'
      }
    )
    expect(prosecutor.offices.map(&:name)).to eq(['Okresná prokuratúra Bratislava IV'])

    prosecutor = Prosecutor.find_by(name: 'JUDr. Michal Bačo')
    expect(prosecutor.name).to eq('JUDr. Michal Bačo')
    expect(prosecutor.name_parts).to eq(
      {
        'last' => 'Bačo',
        'role' => nil,
        'first' => 'Michal',
        'flags' => [],
        'middle' => nil,
        'prefix' => 'JUDr.',
        'suffix' => nil,
        'addition' => nil,
        'unprocessed' => 'Bačo Michal, JUDr.'
      }
    )
    expect(prosecutor.appointments.size).to eq(1)
    expect(prosecutor.appointments.fixed.map { |e| e.office.name }).to eq(['Krajská prokuratúra v Prešove'])

    prosecutor = Prosecutor.find_by(name: 'JUDr. Tomáš Bartko')
    expect(prosecutor.name).to eq('JUDr. Tomáš Bartko')
    expect(prosecutor.name_parts).to eq(
      {
        'last' => 'Bartko',
        'role' => nil,
        'first' => 'Tomáš',
        'flags' => [],
        'middle' => nil,
        'prefix' => 'JUDr.',
        'suffix' => nil,
        'addition' => nil,
        'unprocessed' => 'Bartko Tomáš, JUDr.'
      }
    )
    expect(prosecutor.appointments.size).to eq(2)
    expect(prosecutor.appointments.fixed.map { |e| e.office.name }).to eq(['Okresná prokuratúra Prešov'])
    expect(prosecutor.appointments.temporary.map { |e| e.office.name }).to eq(['Okresná prokuratúra Poprad'])

    prosecutor = Prosecutor.find_by(name: 'Mgr. Branislav Boháčik')
    expect(prosecutor.name).to eq('Mgr. Branislav Boháčik')
    expect(prosecutor.name_parts).to eq(
      {
        'last' => 'Boháčik',
        'role' => nil,
        'first' => 'Branislav',
        'flags' => [],
        'middle' => nil,
        'prefix' => 'Mgr.',
        'suffix' => nil,
        'addition' => nil,
        'unprocessed' => 'Boháčik Branislav, Mgr.'
      }
    )
    expect(prosecutor.appointments.size).to eq(2)
    expect(prosecutor.appointments.fixed.map { |e| e.office.name }).to eq(
      ['Generálna prokuratúra Slovenskej republiky']
    )
    expect(prosecutor.appointments.temporary[0].place).to eq('EUROJUST')
  end
end
