class GoogleNewsJob < ApplicationJob
  def perform(model_name, size: 50)
    model = model_name.constantize
    cache = {}

    ids =
      model.pluck(:id).reject do |id|
        data = Rails.cache.read("#{model.table_name.dasherize}-#{id}-news")

        cache[id] = data if data

        data
      end.first(size)

    ids += cache.sort_by { |_, data| data[:last_updated_at] }.map { |id, _| id }.first(size - ids.size)

    model.where(id: ids).find_each do |record|
      results = GoogleNews.search_by(record.to_news_query)
      urls = results.map { |e| e[:url] }

      previous = (cache[record.id] ? cache[record.id][:data] : []).reject { |result| result[:url].in?(urls) }

      Rails.cache.write(
        "#{model.table_name.dasherize}-#{record.id}-news",
        { last_updated_at: Time.zone.now, data: results + previous },
        expires_in: 0
      )
    end
  end
end
