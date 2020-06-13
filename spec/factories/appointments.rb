# == Schema Information
#
# Table name: appointments
#
#  id                                :bigint           not null, primary key
#  ended_at                          :datetime
#  started_at                        :datetime         not null
#  type                              :integer          not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint           not null
#  office_id                         :bigint           not null
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
FactoryBot.define do
  factory :appointment do
    association :'genpro_gov_sk_prosecutors_list'

    office
    prosecutor
    started_at { Time.zone.now }
  end
end
