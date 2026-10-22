# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GenproGovSk Prosecutors', type: :feature do
  it 'correctly parses all prosecutors' do
    GenproGovSk::Offices.import
    GenproGovSk::Prosecutors.import

    # The recorded list's prosecutors (spec/fixtures/vcr/live_sources/genpro_gov_sk/prosecutors), each with the office
    # and the temporary office the list gives.
    expected_prosecutors =
      JSON.parse(File.read(Rails.root.join('spec/fixtures/genpro_gov_sk/prosecutors/live_list.json')))

    expect(Prosecutor.count).to eq(expected_prosecutors.size)

    places = ->(appointments) { appointments.map { |e| e.office&.name || e.place } }
    imported = Prosecutor.includes(appointments: :office).map do |prosecutor|
      [prosecutor.name, places.call(prosecutor.appointments.select(&:fixed?)),
       places.call(prosecutor.appointments.select(&:temporary?))]
    end

    expect(imported).to match_array(
      expected_prosecutors.map { |e| [e['name'], [e['office']], [e['temporary_office']].compact] }
    )

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
    # The list of 5 October 2026 has him at Poprad, no longer at Prešov.
    expect(prosecutor.appointments.size).to eq(1)
    expect(prosecutor.appointments.fixed.map { |e| e.office.name }).to eq(['Okresná prokuratúra Poprad'])

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
    # The list of 5 October 2026 has him at the General Prosecutor's Office only, no longer at Eurojust.
    expect(prosecutor.appointments.size).to eq(1)
    expect(prosecutor.appointments.fixed.map do |e|
      e.office.name
    end).to eq(['Generálna prokuratúra Slovenskej republiky'])

    prosecutor = Prosecutor.find_by(name: 'JUDr. Jozef Halkoci')
    expect(prosecutor.appointments.fixed.map { |e| e.office.name }).to eq(['Okresná prokuratúra Poprad'])
    expect(prosecutor.appointments.temporary.map { |e| e.office.name }).to eq(['Okresná prokuratúra Kežmarok'])

    prosecutor = Prosecutor.find_by(name: 'JUDr. Lucia Čentéšová')
    expect(prosecutor.appointments.fixed.map do |e|
      e.office.name
    end).to eq(['Generálna prokuratúra Slovenskej republiky'])
    expect(prosecutor.appointments.temporary.map(&:place)).to eq(['Justičná akadémia SR'])
  end
end
