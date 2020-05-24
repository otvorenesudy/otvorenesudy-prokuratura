FactoryBot.define do
  factory :'genpro_gov_sk/prosecutors_list' do
    data { { a: 123 } }
    file { '123' }
    digest { Digest::MD5.hexdigest('123') }
  end
end
