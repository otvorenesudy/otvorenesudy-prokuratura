# frozen_string_literal: true

module CrimesHelper
  def crimes_subtitle(search)
    title = crimes_metrics_title(search)
    paragraphs = Array(search.current_statistic_paragraphs).compact - %w[_all]

    return title if paragraphs.empty?

    list = paragraphs_subtitle_list(paragraphs) do |value|
      crimes_path(search_params(search.params.merge(paragraph: paragraphs), { paragraph: value }))
    end

    safe_join([title, t('crimes.index.by_paragraphs_subtitle_html', paragraphs: list)], ' ')
  end

  private

  def crimes_metrics_title(search)
    metrics = search.current_statistic_metrics.map(&:to_sym)
    groups = Crime::GROUPS.select { |_, values| metrics.intersect?(values) }.keys
    titles = groups.filter_map { |group| I18n.t("crimes.index.search.#{group}.title", default: nil) }

    return titles.to_sentence unless search.monetary_metric_present?
    return I18n.t('crimes.index.monetary_subtitle') if metrics.one?

    [*titles, I18n.t('crimes.index.monetary_subtitle')].to_sentence
  end
end
