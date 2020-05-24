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
        expect { GenproGovSk::ProsecutorsList.import_from(data: { a: 123 }, file: '123') }.to change {
          GenproGovSk::ProsecutorsList.where(digest: Digest::MD5.hexdigest('123')).count
        }.by(1)
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
