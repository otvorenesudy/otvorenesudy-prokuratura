module CrimesHelper
  def crimes_subtitle(search)
    metrics = search.current_statistic_metrics.map(&:to_sym)
    paragraphs = search.current_statistic_paragraphs
    groups = Crime::GROUPS.select { |group, values| (metrics & values).any? }.keys
    key = search.default_params? ? 'crimes.index.subtitle_for_default_params' : 'crimes.index.subtitle'

    translations = groups.map { |group| I18n.t("crimes.index.search.#{group}.title", default: nil) }.compact

    if search.monetary_metric_present?
      search.current_statistic_metrics.size > 1 ?
        translations << I18n.t('crimes.index.monetary_subtitle') :
        translations = [I18n.t('crimes.index.monetary_subtitle')]
    end

    paragraphs -= %w[_all] if paragraphs

    return translations.to_sentence.html_safe if paragraphs&.compact.blank?

    paragraph_names = paragraphs.map { |value| Paragraph.by_value[value] }

    paragraphs_list =
      content_tag :div, class: 'mt-3' do
        content_tag :small do
          content_tag :ul, class: 'list-unstyled ml-3 paragraphs-list' do
            paragraph_names
              .map do |name|
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
                        crimes_path(
                          search_params(
                            @search.params.merge(paragraph: paragraphs),
                            { paragraph: Paragraph.by_name[name] }
                          )
                        ),
                        class: 'flex-fill ml-2 cancel'
                      )
                  ).html_safe
                end
              end
              .join
              .html_safe
          end
        end
      end

    [
      translations.to_sentence,
      I18n.t('crimes.index.by_paragraphs_subtitle', paragraphs: paragraphs_list).html_safe
    ].join(' ').html_safe
  end
end
