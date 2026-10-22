# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Prosecutors do
  describe '.import' do
    let(:list) { %r{/fileadmin/Menny_zoznam_prokuratorov_SR/2026/Menny_zoznam_prokuratorov_SR_k_2026_10_05\.pdf} }

    before do
      stub_source('https://www.genpro.gov.sk/menny-zoznam-prokuratorov-slovenskej-republiky',
                  'genpro_gov_sk/prosecutors/listing.html')
      stub_source(list, 'genpro_gov_sk/prosecutors/list-page-1.pdf')
    end

    it 'imports the prosecutors of the latest list, appointed to their offices' do
      described_class.import

      adamcova = Prosecutor.find_by!(name: 'JUDr. Ingrid Adamcová')

      expect(Prosecutor.count).to eq(27)
      expect(adamcova.name_parts).to include('first' => 'Ingrid', 'last' => 'Adamcová')
      expect(adamcova.offices.map(&:name)).to eq(['Generálna prokuratúra Slovenskej republiky'])
      expect(Appointment.current.temporary.count).to eq(1)
    end

    it 'imports a list once, unless forced, and ends the appointments of those it no longer names' do
      described_class.import
      retired = create(:prosecutor, name: 'JUDr. Bývalý Prokurátor')
      create(:appointment, prosecutor: retired, office: Office.first)

      described_class.import

      expect(retired.appointments.reload).to be_present

      described_class.import(force: true)

      expect(retired.appointments.reload).to be_empty
      expect(retired.past_appointments.count).to eq(1)
      digest = Digest::MD5.hexdigest(fixture('genpro_gov_sk/prosecutors/list-page-1.pdf').binread)
      expect(GenproGovSk::ProsecutorsList.where(digest:).count).to eq(1)
    end
  end
end
