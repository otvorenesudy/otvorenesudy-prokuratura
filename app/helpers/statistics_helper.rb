module StatisticsHelper
  def statistics_subtitle(metric, paragraphs)
    group = Statistic::GROUPS.find { |group, values| metric.to_sym.in?(values) }[0]

    translation = I18n.t("models.statistic.metrics.#{metric}")
    translation = "#{I18n.t("statistics.index.search.#{group}.title")} – #{translation}" unless group == :other

    return I18n.t('statistics.index.subtitle', metric: translation) if paragraphs.values.flatten.compact.blank?

    I18n.t('statistics.index.subtitle_with_paragraphs', metric: translation)
  end
end
