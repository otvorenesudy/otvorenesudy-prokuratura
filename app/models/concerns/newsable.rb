# frozen_string_literal: true

module Newsable
  extend ActiveSupport::Concern

  EXCLUDED_URLS = Rails.root.join('data/newsable/excluded-urls.txt').readlines.map(&:strip)

  class_methods do
    def remove_excluded_urls_from_news!
      find_each do |record|
        next if !record.news || !record.news['data']

        record.news['data'] = record.news['data'].reject do |e|
          EXCLUDED_URLS.any? do |url|
            a = URI.parse(e['url'])
            b = URI.parse(url)

            a.host == b.host && (a.path.match(b.path) || b.path.match(a.path))
          end
        end

        record.save! if record.changed?
      end
    end
  end

  def articles
    news ? news['data'].first(20) : []
  end
end
