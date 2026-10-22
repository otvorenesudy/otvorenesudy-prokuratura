# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Legacy::Normalizer do
  describe '.partition_person_name' do
    def partition(name, **options)
      described_class.partition_person_name(name, options).compact.reject do |_, value|
        value == []
      end.except(:unprocessed)
    end

    it 'splits a name into its titles before and after, and its first and last names' do
      expect(partition('JUDr. Ján Novák, PhD.'))
        .to eq(value: 'JUDr. Ján Novák, PhD.', prefix: 'JUDr.', first: 'Ján', last: 'Novák', suffix: 'PhD.')
    end

    it 'names a regional court\'s spokesperson with the court' do
      expect(partition('Mgr. Ján Novák, hovorca KS v Trnave')).to eq(
        value: 'Mgr. Ján Novák, hovorca krajského súdu v Trnave', prefix: 'Mgr.', first: 'Ján', last: 'Novák',
        flags: [:representantive], role: 'Hovorca krajského súdu v Trnave'
      )
      expect(partition('Eva Malá, hovorca KS v Žiline')).to include(role: 'Hovorca krajského súdu v Žiline')
      expect(partition('hovorca KS Trenčín')).to eq(
        value: 'Hovorca krajského súdu v Trenčíne', last: '', flags: [:representantive],
        role: 'Hovorca krajského súdu v Trenčíne'
      )
    end

    it 'turns a list\'s "last first, titles" around' do
      expect(partition('Novák Ján, JUDr.', reverse: true))
        .to eq(value: 'JUDr. Ján Novák', prefix: 'JUDr.', first: 'Ján', last: 'Novák')
      expect(partition('Nováková Eva Mária, Mgr.', reverse: true))
        .to eq(value: 'Mgr. Mária Nováková Eva', prefix: 'Mgr.', first: 'Mária', middle: 'Nováková', last: 'Eva')
    end

    it 'keeps a maiden name and a junior or senior' do
      expect(partition('Mgr. Eva Malá rod. Veľká'))
        .to eq(value: 'Mgr. Eva Malá rod. Veľká', prefix: 'Mgr.', first: 'Eva', middle: 'Malá rod.', last: 'Veľká',
               flags: [:born])
      expect(partition('JUDr. Ján Novák ml.')).to eq(value: 'JUDr. Ján Novák ml.', prefix: 'JUDr.', first: 'Ján',
                                                     last: 'Novák', addition: 'ml.', flags: [:relative])
    end

    it 'capitalizes names in capitals, and keeps a double surname' do
      expect(partition('JUDr. Ján NOVÁK')).to eq(value: 'JUDr. Ján Novák', prefix: 'JUDr.', first: 'Ján', last: 'Novák')
      expect(partition('Mgr. Mária Nováková-Malá, PhD., LL.M.'))
        .to eq(value: 'Mgr. Mária Nováková - Malá, PhD.', prefix: 'Mgr.', first: 'Mária', last: 'Nováková - Malá',
               suffix: 'PhD.')
    end

    it 'names a court\'s spokesperson by the court' do
      expect(partition('JUDr. Ján Novák, hovorca KS v Trenčíne')).to include(
        value: 'JUDr. Ján Novák, hovorca krajského súdu v Trenčíne', role: 'Hovorca krajského súdu v Trenčíne'
      )
      expect(partition('hovorca KS Trnava')).to include(value: 'Hovorca krajského súdu v Trnave',
                                                        flags: [:representantive])
    end
  end
end
