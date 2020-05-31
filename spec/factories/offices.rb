FactoryBot.define do
  factory :office do
    association :'genpro_gov_sk_prosecutors_list'

    sequence(:name) { |n| "Office #{n}" }
  end
end
