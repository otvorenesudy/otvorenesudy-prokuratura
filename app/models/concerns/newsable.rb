module Newsable
  extend ActiveSupport::Concern

  def news
    news = Rails.cache.read("#{self.class.table_name.dasherize}-#{id}-news")

    news ? news[:data].first(20) : []
  end
end
