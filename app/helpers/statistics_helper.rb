# frozen_string_literal: true

module StatisticsHelper
  def statistics_subtitle(search)
    key = search.default_params? ? 'statistics.index.subtitle_for_default_params' : 'statistics.index.subtitle'
    metric = statistics_metric_title(search) unless search.default_params?
    paragraphs = Array(search.current_statistic_paragraphs).compact - %w[_all]

    return t(key, metric:) if paragraphs.empty?

    list = paragraphs_subtitle_list(paragraphs) do |value|
      statistics_path(search_params(search.params.merge(paragraph: paragraphs), { paragraph: value }))
    end

    t("#{key}_with_paragraphs_html", metric:, paragraphs: list)
  end

  private

  def statistics_metric_title(search)
    metric = search.current_statistic_metric
    group = Statistic::GROUPS.find { |_, values| metric.to_sym.in?(values) }[0]
    title = I18n.t("statistics.index.search.#{group}.metrics.#{metric}", default: nil)

    return title if title

    title = I18n.t("models.statistic.metrics.#{metric}")

    group == :other ? title : "#{I18n.t("statistics.index.search.#{group}.title")} – #{title}"
  end
end
