FactoryBot.define do
  factory :appointment do
    association :'genpro_gov_sk_prosecutors_list'

    office
    prosecutor
    started_at { Time.zone.now }
  end
end
