require 'rails_helper'

RSpec.describe 'GenproGovSk Prosecutors', type: :feature do
  it 'correctly parses all prosecutors', webmock: :disabled, seeds: true do
    pending

    GenproGovSk::Offices.import
    GenproGovSk::Prosecutors.import

    expect(::Prosecutor.count).to eq(1009)

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

    prosecutor = Prosecutor.find_by(name: 'JUDr. Mgr. Svetlana Močková')
    expect(prosecutor.name).to eq('JUDr. Mgr. Svetlana Močková')
    expect(prosecutor.name_parts).to eq(
      {
        'last' => 'Močková',
        'role' => nil,
        'first' => 'Svetlana',
        'flags' => [],
        'middle' => nil,
        'prefix' => 'JUDr. Mgr.',
        'suffix' => nil,
        'addition' => nil,
        'unprocessed' => 'Močková Svetlana, JUDr. Mgr.'
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
    expect(prosecutor.appointments.size).to eq(2)
    expect(prosecutor.appointments.fixed.map { |e| e.office.name }).to eq(['Krajská prokuratúra v Prešove'])
    expect(prosecutor.appointments.temporary[0].place).to eq('EUROJUST')

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
  end
end
