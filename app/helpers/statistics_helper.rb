module StatisticsHelper
  def statistics_subtitle(filters)
    filter, paragraph = filters[0]
    group = Statistic::GROUPS.find { |group, values| filter.to_sym.in?(values) }[0]

    translation = I18n.t("models.statistic.filters.#{filter}")
    translation = "#{I18n.t("statistics.index.search.#{group}.title")} – #{translation}" unless group == :other

    return I18n.t('statistics.index.subtitle', filter: translation) unless paragraph

    # TODO paragraph
  end
end
