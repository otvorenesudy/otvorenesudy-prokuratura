# frozen_string_literal: true

FactoryBot.define do
  factory :statistic do
    office
    year { 2019 }
    metric { 'accused_all' }
    count { 120 }
  end

  factory :crime do
    year { 2019 }
    metric { 'crime_discovered' }
    count { 1500 }
  end
end
