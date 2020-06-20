# == Schema Information
#
# Table name: genpro_gov_sk_prosecutors_lists
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
#  index_genpro_gov_sk_prosecutors_lists_on_digest  (digest) UNIQUE
#
FactoryBot.define do
  factory :'genpro_gov_sk/prosecutors_list', aliases: %i[genpro_gov_sk_prosecutors_list] do
    data { { a: 123 } }
    sequence(:file) { |n| "File #{n}" }
    digest { Digest::MD5.hexdigest(file) }
  end
end
