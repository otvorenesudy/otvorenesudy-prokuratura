# frozen_string_literal: true

FactoryBot.define do
  factory :'genpro_gov_sk/decree', aliases: %i[genpro_gov_sk_decree] do
    data { { number: '1 Pv 1/24/1101-12' } }
    sequence(:file) { |n| "Decree #{n}" }
    digest { Digest::MD5.hexdigest(file) }
  end

  factory :decree do
    genpro_gov_sk_decree

    sequence(:url) { |n| "https://www.genpro.gov.sk/fileadmin/rozhodnutia/#{n}.pdf" }
    sequence(:number) { |n| "1 Pv #{n}/24/1101-12" }
    sequence(:file_number) { |n| "1 Pv #{n}/24" }
    file_info { 'PDF, 120 kB' }
    file_type { :pdf }
    effective_on { Date.new(2024, 3, 1) }
    published_on { effective_on + 7.days }
    resolution { 'Uznesenie o zastavení trestného stíhania' }
    means_of_resolution { 'Zastavenie trestného stíhania' }
    text { 'Okresná prokuratúra rozhodla takto: trestné stíhanie sa zastavuje.' }
  end
end
