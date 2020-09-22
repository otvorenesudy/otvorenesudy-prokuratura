module Newsable
  extend ActiveSupport::Concern

  def news
    Rails.cache.fetch("#{self.class.table_name.dasherize}-#{id}-news", expires_in: 0) { News.search_by(to_news_query) }
  end

  def news!
    Rails.cache.delete("#{self.class.table_name.dasherize}-#{id}-news")

    news
  end
end
