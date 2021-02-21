module Newsable
  extend ActiveSupport::Concern

  EXCLUDED_URLS = File.readlines(Rails.root.join('data', 'newsable', 'excluded-urls.txt')).map(&:strip)

  class_methods do
    def remove_excluded_urls_from_news!
      find_each do |record|
        next if !record.news || !record.news['data']

        record.news['data'] = record.news['data'].reject { |e| EXCLUDED_URLS.any? { |url| e['url'].match(url) } }

        record.save! if record.changed?
      end
    end
  end

  def articles
    news ? news['data'].first(20) : []
  end
end
