FactoryBot.define do
  factory :'genpro_gov_sk/office', aliases: %i[genpro_gov_sk_office] do
    data { { name: 'Generálna Prokuratúra Slovenskej republiky' } }
    sequence(:file) { |n| "File #{n}" }
    digest { Digest::MD5.hexdigest(file) }
  end
end
