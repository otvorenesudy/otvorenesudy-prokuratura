module StatisticsHelper
  def statistics_subtitle(search)
    metric = search.current_statistic_metric
    paragraphs = search.current_statistic_paragraphs
    group = Statistic::GROUPS.find { |group, values| metric.to_sym.in?(values) }[0]
    key = search.default_params? ? 'statistics.index.subtitle_for_default_params' : 'statistics.index.subtitle'

    unless search.default_params?
      translation = I18n.t("statistics.index.search.#{group}.metrics.#{metric}", default: nil)

      unless translation
        translation = I18n.t("models.statistic.metrics.#{metric}")
        translation = "#{I18n.t("statistics.index.search.#{group}.title")} – #{translation}" unless group == :other
      end
    end

    paragraphs -= %w[_all] if paragraphs

    return I18n.t(key, metric: translation) if paragraphs&.compact.blank?

    paragraph_names = paragraphs.map { |value| Paragraph.by_value[value] }

    paragraphs_list =
      content_tag :div, class: 'mt-3' do
        content_tag :small do
          content_tag :ul, class: 'list-unstyled ml-3 paragraphs-list' do
            paragraph_names.map do |name|
              content_tag(:li, class: 'mt-1 d-flex') do
                (
                  content_tag(:span, name, class: 'text-truncate') +
                    (
                      if Paragraph.type_of(Paragraph.by_name[name]) == :old
                        content_tag(:span, class: 'ml-2 facet-tag') do
                          tooltip_tag(
                            I18n.t('statistics.index.search.paragraph.old.badge'),
                            I18n.t('statistics.index.search.paragraph.old.title')
                          )
                        end
                      else
                        ''
                      end
                    ) +
                    link_to(
                      '&times;'.html_safe,
                      statistics_path(
                        search_params(
                          @search.params.merge(paragraph: paragraphs),
                          { paragraph: Paragraph.by_name[name] }
                        )
                      ),
                      class: 'flex-fill ml-2 cancel'
                    )
                ).html_safe
              end
            end.join.html_safe
          end
        end
      end

    I18n.t("#{key}_with_paragraphs", metric: translation, paragraphs: paragraphs_list).html_safe
  end
end
