module Newsable
  extend ActiveSupport::Concern

  def articles
    news ? news['data'].first(20) : []
  end
end
