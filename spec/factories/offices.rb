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
    address { 'Hlavná 1, 123 45 Bratislava' }
    email { 'prokuratura@genpro.gov.sk' }
    phone { '+421 123 456 789' }

    registry do
      {
        phone: '+421 987 654 321',
        hours: {
          monday: %w[08:00 15:00],
          tuesday: %w[08:00 15:00],
          wedneysday: %w[08:00 15:00],
          thursday: %w[08:00 15:00],
          friday: %w[08:00 15:00]
        }
      }
    end
  end
end
