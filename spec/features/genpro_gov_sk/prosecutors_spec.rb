# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GenproGovSk Prosecutors' do
  # The recorded list's prosecutors (spec/fixtures/vcr/live_sources/genpro_gov_sk/prosecutors), each with the office
  # and the temporary office the list gives.
  let(:expected) { JSON.parse(fixture('genpro_gov_sk/prosecutors/live_list.json').read) }

  def places(appointments)
    appointments.map { |appointment| appointment.office&.name || appointment.place }
  end

  def appointments_of(name)
    prosecutor = Prosecutor.find_by!(name:)

    { fixed: places(prosecutor.appointments.fixed), temporary: places(prosecutor.appointments.temporary) }
  end

  def name_parts(first:, last:, prefix:, unprocessed:, middle: nil)
    { 'first' => first, 'middle' => middle, 'last' => last, 'prefix' => prefix, 'suffix' => nil, 'addition' => nil,
      'flags' => [], 'role' => nil, 'unprocessed' => unprocessed }
  end

  def names
    ['Mgr. Martin Draľ', 'JUDr. Mgr. Svetlana Žilková Močková', 'JUDr. Michal Bačo', 'JUDr. Tomáš Bartko',
     'Mgr. Branislav Boháčik']
  end

  # The list of 5 October 2026 has Bartko at Poprad, no longer at Prešov, and Boháčik at the General Prosecutor's
  # Office only, no longer at Eurojust.
  def appointments
    {
      'Mgr. Martin Draľ' => { fixed: ['Krajská prokuratúra v Košiciach'], temporary: [] },
      'JUDr. Mgr. Svetlana Žilková Močková' => { fixed: ['Okresná prokuratúra Bratislava IV'], temporary: [] },
      'JUDr. Michal Bačo' => { fixed: ['Krajská prokuratúra v Prešove'], temporary: [] },
      'JUDr. Tomáš Bartko' => { fixed: ['Okresná prokuratúra Poprad'], temporary: [] },
      'Mgr. Branislav Boháčik' => { fixed: ['Generálna prokuratúra Slovenskej republiky'], temporary: [] },
      'JUDr. Jozef Halkoci' => { fixed: ['Okresná prokuratúra Poprad'], temporary: ['Okresná prokuratúra Kežmarok'] },
      'JUDr. Lucia Čentéšová' => {
        fixed: ['Generálna prokuratúra Slovenskej republiky'], temporary: ['Justičná akadémia SR']
      }
    }
  end

  def parts
    {
      'Mgr. Martin Draľ' => name_parts(first: 'Martin', last: 'Draľ', prefix: 'Mgr.', unprocessed: 'Draľ Martin, Mgr.'),
      'JUDr. Mgr. Svetlana Žilková Močková' => name_parts(
        first: 'Svetlana', middle: 'Žilková', last: 'Močková', prefix: 'JUDr. Mgr.',
        unprocessed: 'Žilková Močková Svetlana, JUDr. Mgr.'
      ),
      'JUDr. Michal Bačo' => name_parts(
        first: 'Michal', last: 'Bačo', prefix: 'JUDr.', unprocessed: 'Bačo Michal, JUDr.'
      ),
      'JUDr. Tomáš Bartko' => name_parts(
        first: 'Tomáš', last: 'Bartko', prefix: 'JUDr.', unprocessed: 'Bartko Tomáš, JUDr.'
      ),
      'Mgr. Branislav Boháčik' => name_parts(
        first: 'Branislav', last: 'Boháčik', prefix: 'Mgr.', unprocessed: 'Boháčik Branislav, Mgr.'
      )
    }
  end

  it 'imports every prosecutor of the recorded list with the parts of their name, at their offices' do
    GenproGovSk::Offices.import
    GenproGovSk::Prosecutors.import

    imported = Prosecutor.includes(appointments: :office).map do |prosecutor|
      [prosecutor.name, places(prosecutor.appointments.select(&:fixed?)),
       places(prosecutor.appointments.select(&:temporary?))]
    end

    expect(Prosecutor.count).to eq(expected.size)
    expect(imported).to match_array(expected.map { |e| [e['name'], [e['office']], [e['temporary_office']].compact] })
    expect(names.index_with { |name| Prosecutor.find_by!(name:).name_parts }).to eq(parts)
    expect(appointments.keys.index_with { |name| appointments_of(name) }).to eq(appointments)
  end
end
