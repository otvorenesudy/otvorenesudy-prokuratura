# frozen_string_literal: true

require 'google/apis/customsearch_v1'

# News about offices and prosecutors from three newspapers, through Google Custom Search.
class GoogleNews
  SOURCES = { 'sme.sk' => 'SME', 'dennikn.sk' => 'Denník N', 'aktuality.sk' => 'Aktuality' }.freeze

  def self.search_by(name)
    searched_at = Time.zone.now.to_i

    Array(search(name)).map { |result| article(result, searched_at:) }
  end

  def self.search_url_for(record)
    "https://google.com/search?q=#{
      record.to_news_query
    } prokurátor prokuratúra site:dennikn.sk OR site:aktuality.sk OR site:sme.sk"
  end

  # Searches again for the records (all the given ones, or as many as `size` of those waiting the longest), the latest
  # articles before what each had.
  def self.cache_for(model, size: 50, ids: nil)
    ids ||= ids_to_refresh(model, size)

    model.where(id: ids).find_each do |record|
      results = search_by(record.to_news_query)
      urls = results.pluck(:url)
      previous = (record.news ? record.news['data'] : []).reject { |result| result['url'].in?(urls) }

      record.update!(news: { last_updated_at: Time.zone.now.to_i, data: results + previous })
    end
  end

  class << self
    private

    def search(name)
      service = Google::Apis::CustomsearchV1::CustomSearchAPIService.new
      service.key = Rails.application.credentials.dig(:google, :api, :search, :key)

      service.list_cses(
        exact_terms: name,
        or_terms: 'prokurátor|prokuratúra',
        cx: Rails.application.credentials.dig(:google, :api, :search, :id),
        num: 10,
        sort: 'date:d:s'
      ).items
    end

    # A search result, with the title and description its page gives for sharing where it has them.
    def article(result, searched_at:)
      host = URI.parse(result.link).host
      tags = result.pagemap.try { |pagemap| pagemap['metatags'] }&.find { |values| values['og:title'] }
      snippet = tags&.fetch('og:description', nil) || result.snippet

      {
        title: tags&.fetch('og:title', nil) || result.title,
        snippet: snippet.gsub(/[[:space:]]+/, ' '),
        url: result.link,
        source: SOURCES.find { |domain, _| host.match?(domain) }&.last,
        searched_at:
      }
    end

    # The records without news first, then those updated the longest ago.
    def ids_to_refresh(model, size)
      ids = model.where(news: nil).first(size).pluck(:id)

      ids + model.where.not(news: nil).order(Arel.sql("(news -> 'last_updated_at') :: int")).limit(size - ids.size).ids
    end
  end
end
