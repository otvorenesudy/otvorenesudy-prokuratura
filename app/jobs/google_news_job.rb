class GoogleNewsJob < ApplicationJob
  def perform(model_name, size: 50)
    model = model_name.constantize
    cache = {}

    ids = model.where(news: nil).first(size)
    ids += model.where.not(news: nil).order("(news -> 'last_updated_at') :: int").limit(size - ids.size).pluck(:id)

    model.where(id: ids).find_each do |record|
      results = GoogleNews.search_by(record.to_news_query)
      urls = results.map { |e| e[:url] }
      data = record.news ? record.news['data'] : []
      previous = data.reject { |result| result['url'].in?(urls) }

      record.news = { last_updated_at: Time.zone.now.to_i, data: results + previous }

      record.save!
    end
  end
end
