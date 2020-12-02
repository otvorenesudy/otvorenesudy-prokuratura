module Newsable
  extend ActiveSupport::Concern

  EXCLUDED_URLS = %w[
    https://e.dennikn.sk/682996/sef-agrokomplexu-z-sns-uz-stihol-zamestnat-dceru-poslankyne-a-pohnevat-si-50-firiem/1738949
  ]

  class_methods do
    def remove_excluded_urls_from_news
      find_each do |record|
        next if !record.news || !record.news['data']

        record.news['data'] = record.news['data'].reject { |e| EXCLUDED_URLS.any? { |url| e['url'].match(url) } }

        record.save!
      end
    end
  end

  def articles
    news ? news['data'].first(20) : []
  end
end
