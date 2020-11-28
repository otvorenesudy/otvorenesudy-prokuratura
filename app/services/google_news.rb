require 'google/apis/customsearch_v1'

class GoogleNews
  def self.search_by(name)
    service = Google::Apis::CustomsearchV1::CustomSearchAPIService.new
    service.key = Rails.application.credentials.dig(:google, :api, :search, :key)
    pages = [0, 11]

    pages.map do |start|
      results =
        service.list_cse_siterestricts(
          exact_terms: name,
          or_terms: 'prokurátor|prokuratúra',
          cx: Rails.application.credentials.dig(:google, :api, :search, :id),
          num: 10,
          start: start
        ).items

      searched_at = Time.zone.now

      return [] if results.blank?

      results.map do |result|
        uri = URI.parse(result.link)
        source = 'SME' if uri.host.match('sme.sk')
        source = 'Denník N' if uri.host.match('dennikn.sk')
        source = 'Aktuality' if uri.host.match('aktuality.sk')
        title =
          result.pagemap.try { |e| e['metatags']&.find { |e| e['og:title'] }&.fetch('og:title', nil) } || result.title
        snippet =
          result.pagemap.try { |e| e['metatags']&.find { |e| e['og:title'] }&.fetch('og:description', nil) } ||
            result.snippet

        {
          title: title,
          snippet: snippet.gsub(/[[:space:]]+/, ' '),
          url: result.link,
          source: source,
          searched_at: searched_at.to_i
        }
      end
    end.flatten
  end

  def self.search_url_for(record)
    "https://google.com/search?q=#{
      record.to_news_query
    } prokurátor prokuratúra site:dennikn.sk OR site:aktuality.sk OR site:sme.sk"
  end

  def self.cache_for(model)
    model.find_each do |record|
      results = GoogleNews.search_by(record.to_news_query)
      urls = results.map { |e| e[:url] }
      data = record.news ? record.news['data'] : []
      previous = data.reject { |result| result['url'].in?(urls) }

      record.news = { last_updated_at: Time.zone.now.to_i, data: results + previous }

      record.save!
    end
  end
end
