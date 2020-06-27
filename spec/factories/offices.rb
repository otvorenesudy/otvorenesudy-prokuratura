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
FactoryBot.define do
  factory :office do
    association :'genpro_gov_sk_office'

    type { :district }

    sequence(:name) { |n| "Office #{n}" }
    address { 'Hlavná 1, 123 45 Bratislava' }
    email { 'prokuratura@genpro.gov.sk' }
    phone { '+421 123 456 789' }

    registry do
      {
        phone: '+421 987 654 321',
        hours: {
          monday: '08:00 - 15:00',
          tuesday: '08:00 - 15:00',
          wednesday: '08:00 - 15:00',
          thursday: '8:00 - 15:00',
          friday: '08:00 - 15:00'
        }
      }
    end
  end
end
