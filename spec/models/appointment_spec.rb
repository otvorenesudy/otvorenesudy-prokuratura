# == Schema Information
#
# Table name: appointments
#
#  id                                :bigint           not null, primary key
#  ended_at                          :datetime
#  place                             :string
#  started_at                        :datetime         not null
#  type                              :integer          not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint
#  office_id                         :bigint
#  prosecutor_id                     :bigint           not null
#
# Indexes
#
#  index_appointments_on_genpro_gov_sk_prosecutors_list_id  (genpro_gov_sk_prosecutors_list_id)
#  index_appointments_on_office_id                          (office_id)
#  index_appointments_on_prosecutor_id                      (prosecutor_id)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_prosecutors_list_id => genpro_gov_sk_prosecutors_lists.id)
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (prosecutor_id => prosecutors.id)
#
require 'rails_helper'

RSpec.describe Appointment, type: :model do
  subject { build(:appointment, place: 'place') }

  it { is_expected.to belong_to(:genpro_gov_sk_prosecutors_list) }
  it { is_expected.to belong_to(:prosecutor) }
  it { is_expected.to belong_to(:office).optional(true) }
  it { is_expected.to validate_presence_of(:started_at) }
  it { is_expected.to define_enum_for(:type).with_values(%i[fixed temporary]) }

  context 'without office' do
    subject { build(:appointment, office: nil) }

    it { is_expected.to validate_presence_of(:place) }
  end
end
