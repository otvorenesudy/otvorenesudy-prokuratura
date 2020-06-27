# == Schema Information
#
# Table name: genpro_gov_sk_offices
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  digest     :string           not null
#  file       :binary           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_genpro_gov_sk_offices_on_digest  (digest) UNIQUE
#
FactoryBot.define do
  factory :'genpro_gov_sk/office', aliases: %i[genpro_gov_sk_office] do
    data { { name: 'Generálna Prokuratúra Slovenskej republiky' } }
    sequence(:file) { |n| "File #{n}" }
    digest { Digest::MD5.hexdigest(file) }
  end
end
