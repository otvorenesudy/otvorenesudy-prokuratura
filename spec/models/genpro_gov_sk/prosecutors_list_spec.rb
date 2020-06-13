# == Schema Information
#
# Table name: genpro_gov_sk_prosecutors_lists
#
#  id         :bigint           not null, primary key
#  data       :json             not null
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

RSpec.describe GenproGovSk::ProsecutorsList, type: :model do
  subject { build(:'genpro_gov_sk/prosecutors_list') }

  it { is_expected.to validate_presence_of(:data) }
  it { is_expected.to validate_presence_of(:file) }
  it { is_expected.to validate_presence_of(:digest) }
  it { is_expected.to validate_uniqueness_of(:digest) }

  describe '.import_from' do
    context 'with new file' do
      it 'saves the list' do
        office = create(:office, name: "Attorney General's Office")

        expect {
          GenproGovSk::ProsecutorsList.import_from(
            data: [{ id: '1', name: 'JUDr. John Smith', office: "Attorney General's Office" }], file: '123'
          )
        }.to change { GenproGovSk::ProsecutorsList.where(digest: Digest::MD5.hexdigest('123')).count }.by(1)

        prosecutor = Prosecutor.order(:id).last

        expect(prosecutor.name).to eql('JUDr. John Smith')
        expect(prosecutor.genpro_gov_sk_prosecutors_list).to eql(
          GenproGovSk::ProsecutorsList.find_by(digest: Digest::MD5.hexdigest('123'))
        )
        expect(prosecutor.appointments.size).to eql(1)
        expect(prosecutor.appointments[0].office).to eql(office)
        expect(prosecutor.appointments[0]).to be_fixed
        expect(prosecutor.appointments[0]).to be_current
      end
    end

    context 'with new file and already imported prosecutors' do
      it 'correctly handles added temporary office' do
        offices = [create(:office, name: "Attorney General's Office"), create(:office, name: 'ABC')]

        expect {
          GenproGovSk::ProsecutorsList.import_from(
            data: [{ id: '1', name: 'JUDr. John Smith', office: "Attorney General's Office" }], file: '123'
          )
        }.to change { GenproGovSk::ProsecutorsList.where(digest: Digest::MD5.hexdigest('123')).count }.by(1)

        expect {
          GenproGovSk::ProsecutorsList.import_from(
            data: [{ id: '1', name: 'JUDr. John Smith', office: "Attorney General's Office", temporary_office: 'ABC' }],
            file: '1234'
          )
        }.to change { GenproGovSk::ProsecutorsList.where(digest: Digest::MD5.hexdigest('1234')).count }.by(1)

        prosecutor = Prosecutor.order(:id).last

        expect(prosecutor.name).to eql('JUDr. John Smith')
        expect(prosecutor.genpro_gov_sk_prosecutors_list).to eql(
          GenproGovSk::ProsecutorsList.find_by(digest: Digest::MD5.hexdigest('123'))
        )
        expect(prosecutor.appointments.size).to eql(2)

        appointments = prosecutor.appointments.order(id: :asc)

        expect(appointments[0].office).to eql(offices[0])
        expect(appointments[0]).to be_fixed
        expect(appointments[0]).to be_current
        expect(appointments[1].office).to eql(offices[1])
        expect(appointments[1]).to be_temporary
        expect(appointments[1]).to be_current
      end

      it 'correctly handles changed office' do
        offices = [create(:office, name: "Attorney General's Office"), create(:office, name: 'ABC')]

        expect {
          GenproGovSk::ProsecutorsList.import_from(
            data: [{ id: '1', name: 'JUDr. John Smith', office: "Attorney General's Office" }], file: '123'
          )
        }.to change { GenproGovSk::ProsecutorsList.where(digest: Digest::MD5.hexdigest('123')).count }.by(1)

        expect {
          GenproGovSk::ProsecutorsList.import_from(
            data: [{ id: '1', name: 'JUDr. John Smith', office: 'ABC' }], file: '1234'
          )
        }.to change { GenproGovSk::ProsecutorsList.where(digest: Digest::MD5.hexdigest('1234')).count }.by(1)

        prosecutors = Prosecutor.order(:id).first(2)

        expect(prosecutors[0].name).to eql('JUDr. John Smith')
        expect(prosecutors[1].name).to eql('JUDr. John Smith')

        expect(prosecutors[0].genpro_gov_sk_prosecutors_list).to eql(
          GenproGovSk::ProsecutorsList.find_by(digest: Digest::MD5.hexdigest('123'))
        )
        expect(prosecutors[0].appointments.size).to eql(1)

        expect(prosecutors[1].genpro_gov_sk_prosecutors_list).to eql(
          GenproGovSk::ProsecutorsList.find_by(digest: Digest::MD5.hexdigest('1234'))
        )
        expect(prosecutors[1].appointments.size).to eql(1)

        appointments = prosecutors[0].appointments.order(id: :asc)

        expect(appointments[0].office).to eql(offices[0])
        expect(appointments[0]).to be_fixed
        expect(appointments[0]).to be_current

        appointments = prosecutors[1].appointments.order(id: :asc)

        expect(appointments[0].office).to eql(offices[1])
        expect(appointments[0]).to be_fixed
        expect(appointments[0]).to be_current
      end
    end

    context 'with already processed file' do
      it 'does nothing' do
        create(:'genpro_gov_sk/prosecutors_list', file: '123')

        expect { GenproGovSk::ProsecutorsList.import_from(data: { a: 123 }, file: '123') }.not_to change {
          GenproGovSk::ProsecutorsList.where(digest: Digest::MD5.hexdigest('123')).count
        }
      end
    end
  end
end
