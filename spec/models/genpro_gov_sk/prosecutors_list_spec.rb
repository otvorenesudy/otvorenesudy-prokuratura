# frozen_string_literal: true

# == Schema Information
#
# Table name: genpro_gov_sk_prosecutors_lists
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  digest     :string           not null
#  file       :binary           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_genpro_gov_sk_prosecutors_lists_on_digest  (digest) UNIQUE
#
require 'rails_helper'

RSpec.describe GenproGovSk::ProsecutorsList do
  subject { build(:'genpro_gov_sk/prosecutors_list') }

  it { is_expected.to validate_presence_of(:data) }
  it { is_expected.to validate_presence_of(:file) }
  it { is_expected.to validate_presence_of(:digest) }
  it { is_expected.to validate_uniqueness_of(:digest) }

  describe '.import_from' do
    let(:general) { create(:office, name: "Attorney General's Office") }
    let(:other) { create(:office, name: 'ABC') }

    def import(file, office:, temporary_office: nil)
      data = { id: '1', name: 'JUDr. John Smith', name_parts: { value: 'JUDr. John Smith' }, office:,
               temporary_office: }

      described_class.import_from(data: [data.compact], file:)
    end

    def lists_of(file)
      described_class.where(digest: Digest::MD5.hexdigest(file))
    end

    def appointments_of(appointments)
      appointments.order(id: :asc).map { |appointment| [appointment.office, appointment.type, appointment.current?] }
    end

    context 'with new file' do
      it 'saves the list and appoints its prosecutor to the office' do
        expect { import('123', office: general.name) }.to change { lists_of('123').count }.by(1)

        prosecutor = Prosecutor.order(:id).last

        expect(prosecutor)
          .to have_attributes(name: 'JUDr. John Smith', genpro_gov_sk_prosecutors_list: lists_of('123').first)
        expect(appointments_of(prosecutor.appointments)).to eq([[general, 'fixed', true]])
      end
    end

    context 'with new file and already imported prosecutors' do
      it 'adds a temporary office the list now gives' do
        import('123', office: general.name)

        expect { import('1234', office: general.name, temporary_office: other.name) }
          .to change { lists_of('1234').count }.by(1)

        prosecutor = Prosecutor.order(:id).last

        expect(prosecutor.genpro_gov_sk_prosecutors_list).to eq(lists_of('123').first)
        expect(appointments_of(prosecutor.appointments)).to eq([[general, 'fixed', true], [other, 'temporary', true]])
      end

      it 'ends the appointment at an office the prosecutor left' do
        import('123', office: general.name)

        expect { import('1234', office: other.name) }.to change { lists_of('1234').count }.by(1)

        prosecutor = Prosecutor.order(:id).last

        expect(prosecutor.genpro_gov_sk_prosecutors_list).to eq(lists_of('123').first)
        expect(appointments_of(prosecutor.all_appointments)).to eq([[general, 'fixed', false], [other, 'fixed', true]])
      end
    end

    context 'with already processed file' do
      it 'does nothing' do
        create(:'genpro_gov_sk/prosecutors_list', file: '123')

        expect { described_class.import_from(data: { a: 123 }, file: '123') }
          .not_to(change { lists_of('123').count })
      end
    end
  end
end
