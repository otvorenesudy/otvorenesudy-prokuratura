require 'rails_helper'

RSpec.describe GenproGovSk::Offices, webmock: :disabled do
  describe '.import' do
    it 'fetches all 63 office URLs and parses them' do
      html = Curl.get('https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/').body_str
      doc = Nokogiri::HTML(html)

      links = doc.css('.tx-tempest-contacts .govuk-table__row td > a').map { |e| "https://www.genpro.gov.sk#{e['href']}" }

      expect(links.size).to eq(63)

      expected_urls = [
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/1/?cHash=ecb79bc6659ada38ee5a511d84dab15e',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/6/?cHash=e28df7466112e1495e4c8cff745982ea',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/7/?cHash=a9628e0f9f1ee7ff5ab75f8c3f7a8c04',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/8/?cHash=bb6674c1c9945b9bccc875b2264d5c23',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/9/?cHash=fb3b1ae40cd816b4fa3f777aab6c1237',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/10/?cHash=f15f5004baee2f79b5239e1d4b6f94c1',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/11/?cHash=3ef6bc83be6afe5c62814d34b5f2084b',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/61/?cHash=da70d7e0df105c36cf00c107f3015fbd',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/60/?cHash=9c2db6b1bddcd36ca847f4443dd62572',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/12/?cHash=5adfa26c218b5c4b70fc20b0737bd2e0',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/13/?cHash=0427be0503fed2e840a7c2137a3df163',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/14/?cHash=f86893864b4202a953ccbc38129ad352',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/62/?cHash=41c4e6de4267c169bc0cc756e40b8a1a',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/15/?cHash=fbd15ea18e9d937c1d5b7abba83e3cad',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/64/?cHash=c420a9a40e4fd22ed6b85b2488b9f4d4',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/16/?cHash=07e7806aca18550b51a678a59392104f',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/17/?cHash=88afbc1625150badbd084c1f76b3e23c',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/59/?cHash=3105229904a32925ddbd29c3ab22172e',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/63/?cHash=2adaafb8b5955463f302bfa2cb6a036f',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/67/?cHash=595a2a235028915182936d464b0a4a79',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/19/?cHash=9873cb2d321a5df7f576e6067ee58648',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/20/?cHash=480abccf1e089644a107278d10c016f5',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/18/?cHash=a3d126212af643bbc2c75e28f27f0e20',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/21/?cHash=79c256bf9b074afb8532f44a28cb59d7',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/58/?cHash=ab1b7d93cb7fb245ae91d2b2418e42ef',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/23/?cHash=ab3304e06a348063499a7948cfaf03d2',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/22/?cHash=a36a711a897a5cb1606ffbde023c6def',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/24/?cHash=b998f1ed6bb71be3919d9e348e848274',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/25/?cHash=fc3651ab251a48cf61e15bd2ea8f81f4',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/26/?cHash=1a4eed095c6e91d037de09f6e603f13b',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/28/?cHash=053a34092104e85e92721ba1ac962b87',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/29/?cHash=cb55510c854f97166b6813966c06fc80',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/30/?cHash=ef42e0c8c06bc88fadd61ccfcb0a5043',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/31/?cHash=bb5f6502421051a913542ace02e61b47',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/65/?cHash=9f0b45057a6d593fb0ae9b6b19d0e565',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/32/?cHash=244e048d54e5f920710be1d48f22ca3d',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/27/?cHash=25ae1dbe388c63240512f12d3f6b0493',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/33/?cHash=9f82eb0f1bbe34060b8e687b9f5a5590',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/34/?cHash=4b754667725a2b27284befd87f6902c4',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/35/?cHash=4c9c7984d978fa2e231e468e48d7e16a',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/36/?cHash=055965286319b9cd92ff9ff9d02253a3',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/66/?cHash=362207e868a2dd109fdd855481b6f531',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/37/?cHash=b5d9fcc71ec8a4d6cfc36c8d03075aca',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/38/?cHash=27dfbb25318bb0a18eb61b39ae9dbbf4',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/40/?cHash=c09e2316571d816df910ae7d59221e49',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/39/?cHash=5549b0d1534c61f30a66f9d63acad398',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/41/?cHash=58f78d922eca0e2068e8f59a394ee6c0',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/43/?cHash=d34e8a332aaffc133e2be97716210a5e',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/44/?cHash=5251446cd4b4866e4b5710deb1b49165',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/45/?cHash=7f22ffd0fa1aba2ad0051e7ab041901c',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/46/?cHash=e4728054e0a3f1d411cc1b9a21aaa30e',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/42/?cHash=ede384c07b6015eee331e362b8a80e93',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/47/?cHash=6394dfc5073c873340a87231e29a4347',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/48/?cHash=bc8847d9c203c1a0d4bad6fb407ff73f',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/49/?cHash=30ec5e2c46e7af664f1a5bf5bc0da832',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/50/?cHash=ed8e2f0037995d964edf995269df47cd',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/53/?cHash=cf8924bdc1322959be609e5e36522a85',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/51/?cHash=03424d86642c491373034213820a10fc',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/52/?cHash=83d0cf4de2d8ecaf96a6be3f704d2e77',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/54/?cHash=60d73f4caf09acb4d78c8420141fa776',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/55/?cHash=35179290fca229588b6f33fa1b66d505',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/56/?cHash=8313a326683f93095cfb8d6d8fa27754',
        'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/detail/57/?cHash=c4554213cbc0c7cedc63728ca37b7461'
      ]

      links.each_with_index do |url, index|
        expect(url).to eq(expected_urls[index])
      end

      allow(GenproGovSk::Office).to receive(:import_from)

      described_class.import

      expect(GenproGovSk::Office).to have_received(:import_from).exactly(63).times
    end
  end
end
