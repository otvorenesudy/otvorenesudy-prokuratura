# == Schema Information
#
# Table name: offices
#
#  id                      :bigint           not null, primary key
#  address                 :string(1024)     not null
#  electronic_registry     :string
#  email                   :string
#  fax                     :string
#  name                    :string           not null
#  phone                   :string           not null
#  registry                :jsonb            not null
#  type                    :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  genpro_gov_sk_office_id :bigint           not null
#
# Indexes
#
#  index_offices_on_genpro_gov_sk_office_id  (genpro_gov_sk_office_id)
#  index_offices_on_name                     (name) UNIQUE
#  index_offices_on_type                     (type)
#  index_offices_on_unique_general_type      (type) UNIQUE WHERE (type = 0)
#  index_offices_on_unique_specialized_type  (type) UNIQUE WHERE (type = 1)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_office_id => genpro_gov_sk_offices.id)
#
require 'rails_helper'

RSpec.describe Office, type: :model do
  subject { build(:office) }

  describe 'Validations' do
    it { is_expected.to belong_to(:genpro_gov_sk_office) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:phone) }
    it { is_expected.to validate_presence_of(:registry) }

    it 'validates correct schema of registry' do
      subject.registry = {
        phone: '123',
        hours: {
          monday: '8:00 - 15:00',
          tuesday: '8:00 - 15:00',
          wednesday: '8:00 - 15:00',
          thursday: '8:00 - 15:00',
          friday: '8:00 - 15:00'
        }
      }

      expect(subject).to be_valid

      subject.registry = {
        phone: '123',
        hours: {
          monday: '8:00 - 15:00',
          tuesday: '8:00 - 15:00',
          wednesday: '',
          thursday: '8:00 - 15:00',
          friday: '8:00 - 15:00'
        }
      }

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to eql(['Registry is invalid'])
    end
  end
end
