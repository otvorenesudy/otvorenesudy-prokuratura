# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Prosecutors::Parser do
  describe '.parse' do
    it 'splits an office and a temporary office the list runs together in one cell' do
      row = ['Lichner Michal, Mgr.', 'Okresná prokuratúra Nové Mesto nad Váhom Krajská prokuratúra v Trenčíne']

      expect(described_class.parse([row]).first).to include(
        name: 'Mgr. Michal Lichner', office: 'Okresná prokuratúra Nové Mesto nad Váhom',
        temporary_office: 'Krajská prokuratúra v Trenčíne'
      )
    end

    it 'keeps a cell that goes on past a known office with something that is not one' do
      row = ['Novák Ján, JUDr.', 'Krajská prokuratúra v Trenčíne Okresná prokuratúra na Mesiaci']

      expect { described_class.parse([row]) }.to raise_error(RuntimeError, 'Office not found for Novák Ján, JUDr.')
    end

    it 'refuses a row whose office it does not know' do
      expect { described_class.parse([['Novák Ján, JUDr.', 'Prokuratúra na Mesiaci']]) }
        .to raise_error(RuntimeError, 'Office not found for Novák Ján, JUDr.')
    end
  end
end
