# == Schema Information
#
# Table name: offices
#
#  id                                :bigint           not null, primary key
#  address                           :string(1024)     not null
#  electronic_registry               :string
#  email                             :string           not null
#  fax                               :string
#  name                              :string           not null
#  phone                             :string           not null
#  registry                          :jsonb            not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint           not null
#
# Indexes
#
#  index_offices_on_genpro_gov_sk_prosecutors_list_id  (genpro_gov_sk_prosecutors_list_id)
#  index_offices_on_name                               (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_prosecutors_list_id => genpro_gov_sk_prosecutors_lists.id)
#
FactoryBot.define do
  factory :office do
    association :'genpro_gov_sk_prosecutors_list'

    sequence(:name) { |n| "Office #{n}" }
  end
end
