module Newsable
  extend ActiveSupport::Concern

  EXCLUDED_URLS = [
    'https://e.dennikn.sk/682996/sef-agrokomplexu-z-sns-uz-stihol-zamestnat-dceru-poslankyne-a-pohnevat-si-50-firiem/1738949',
    ''
  ]

  class_methods {}

  def articles
    news ? news['data'].first(20) : []
  end
end
