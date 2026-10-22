# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleNews do
  let(:search) { %r{\Ahttps://customsearch\.googleapis\.com/customsearch/v1\?} }

  def results(*items)
    { status: 200, headers: { 'Content-Type' => 'application/json' }, body: { items: }.to_json }
  end

  def item(link, title, pagemap = nil)
    { link:, title:, snippet: "  O #{title}\n  viac ", pagemap: }.compact
  end

  describe '.cache_for' do
    it 'keeps the latest news about each office, named after their source, before what it had' do
      office = Office.find_by!(name: 'Okresná prokuratúra Žilina')
      office.update!(news: { data: [{ url: 'https://www.sme.sk/old', title: 'Staršia správa' }] })
      stub_request(:get, search).with(query: hash_including(exactTerms: office.name)).to_return(
        results(
          item('https://domov.sme.sk/c/1/prokuratura.html', 'Obžaloba v Žiline'),
          item('https://dennikn.sk/2/', 'Prokurátor', { metatags: [{ 'og:title' => 'Prokurátor podal obžalobu',
                                                                     'og:description' => 'Popis z Denníka N' }] }),
          item('https://www.aktuality.sk/clanok/3/', 'Súd v Žiline')
        )
      )

      travel_to Time.zone.local(2026, 10, 22, 4, 15) do
        described_class.cache_for(Office, ids: [office.id])
      end

      news = office.reload.news

      expect(news['last_updated_at']).to eq(Time.zone.local(2026, 10, 22, 4, 15).to_i)
      expect(news['data'].map { |article| article.values_at('source', 'title') }).to eq(
        [['SME', 'Obžaloba v Žiline'], ['Denník N', 'Prokurátor podal obžalobu'], ['Aktuality', 'Súd v Žiline'],
         [nil, 'Staršia správa']]
      )
      expect(news['data'].map { |article| article['snippet'] }.first(2)).to eq([' O Obžaloba v Žiline viac ',
                                                                                'Popis z Denníka N'])
    end

    it 'takes the title and the snippet from the search, where the page names no title of its own' do
      office = Office.find_by!(name: 'Okresná prokuratúra Žilina')
      stub_request(:get, search).to_return(
        results(
          item('https://dennikn.sk/1/', 'Bez metaúdajov', { cse_image: [{ src: 'https://dennikn.sk/1.jpg' }] }),
          item('https://dennikn.sk/2/', 'Bez titulku', { metatags: [{ 'og:type' => 'article' }] })
        )
      )

      described_class.cache_for(Office, ids: [office.id])

      expect(office.reload.news['data'].map { |article| article.values_at('title', 'snippet') }).to eq(
        [['Bez metaúdajov', ' O Bez metaúdajov viac '], ['Bez titulku', ' O Bez titulku viac ']]
      )
    end

    it 'looks for the General Prosecutor\'s Office by its short name' do
      general = Office.find_by!(name: 'Generálna prokuratúra Slovenskej republiky')
      stub_request(:get, search).to_return(results)

      described_class.cache_for(Office, ids: [general.id])

      expect(a_request(:get, search).with(query: hash_including(exactTerms: 'Generálna prokuratúra'))).to have_been_made
    end

    it 'looks for the prosecutors without news first, then for those updated the longest ago' do
      fresh = create(:prosecutor, news: { last_updated_at: 2.days.ago.to_i, data: [] })
      stale = create(:prosecutor, news: { last_updated_at: 1.week.ago.to_i, data: [] })
      unseen = create(:prosecutor)
      stub_request(:get, search).to_return(results)

      described_class.cache_for(Prosecutor, size: 2)

      expect(a_request(:get, search).with(query: hash_including(exactTerms: unseen.to_news_query))).to have_been_made
      expect(a_request(:get, search).with(query: hash_including(exactTerms: stale.to_news_query))).to have_been_made
      expect(a_request(:get, search).with(query: hash_including(exactTerms: fresh.to_news_query))).not_to have_been_made
      expect(unseen.reload.news['data']).to eq([])
    end
  end

  describe '.search_url_for' do
    it 'searches Google for the prosecutor in the newspapers' do
      prosecutor = create(:prosecutor, name_parts: { first: 'Ján', last: 'Novák' })

      expect(described_class.search_url_for(prosecutor)).to eq(
        'https://google.com/search?q=Ján Novák prokurátor prokuratúra site:dennikn.sk OR site:aktuality.sk OR site:sme.sk'
      )
    end
  end
end
