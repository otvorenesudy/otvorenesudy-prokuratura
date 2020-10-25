require 'google/apis/customsearch_v1'

# NOTE: WIP
class GoogleNews
  def self.search_by(query)
    service = Google::Apis::CustomsearchV1::CustomSearchAPIService.new
    service.key = Rails.application.credentials.dig(:google, :api, :search, :key)

    results =
      service.list_cses(
        exact_terms: query,
        or_terms: 'prokurátor prokuratúra',
        cx: Rails.application.credentials.dig(:google, :api, :search, :id),
        sort: 'date'
      ).items

    return [] if results.blank?

    results.map do |result|
      { title: result.title, snipped: result.snippet.gsub(/[[:space:]]+/, ' '), url: result.link }
    end
  end
end
