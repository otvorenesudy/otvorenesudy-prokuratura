require 'google/apis/customsearch_v1'

class GoogleNews
  def self.search_by(name)
    service = Google::Apis::CustomsearchV1::CustomSearchAPIService.new
    service.key = Rails.application.credentials.dig(:google, :api, :search, :key)

    results =
      service.list_cses(
        exact_terms: name,
        or_terms: 'prokurátor prokuratúra',
        cx: Rails.application.credentials.dig(:google, :api, :search, :id),
        sort: 'date',
        num: 10
      ).items

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

      { title: title, snippet: snippet.gsub(/[[:space:]]+/, ' '), url: result.link, source: source }
    end
  end

  def self.search_url_for(record)
    "https://google.com/search?q=#{
      record.to_news_query
    } prokurátor prokuratúra site:dennikn.sk OR site:aktuality.sk OR site:sme.sk"
  end
end
