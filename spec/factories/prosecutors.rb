FactoryBot.define do
  factory :prosecutor do
    association :'genpro_gov_sk_prosecutors_list'

    sequence(:name) { |n| "JUDr. John Doe #{n}" }
  end
end
