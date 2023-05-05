# == Schema Information
#
# Table name: prosecutors
#
#  id                                :bigint           not null, primary key
#  declarations                      :jsonb
#  decrees                           :jsonb            not null
#  name                              :string           not null
#  name_parts                        :jsonb            not null
#  news                              :jsonb
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint
#
# Indexes
#
#  index_prosecutors_on_genpro_gov_sk_prosecutors_list_id  (genpro_gov_sk_prosecutors_list_id)
#  index_prosecutors_on_name                               (name)
#  index_prosecutors_on_name_parts                         (name_parts)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_prosecutors_list_id => genpro_gov_sk_prosecutors_lists.id)
#
FactoryBot.define do
  factory :prosecutor do
    association :'genpro_gov_sk_prosecutors_list'

    sequence(:name) { |n| "JUDr. John Doe #{n}" }
  end
end
