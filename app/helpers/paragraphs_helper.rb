# frozen_string_literal: true

module ParagraphsHelper
  # The paragraphs a criminality chart is narrowed to, under its title: each with the badge of the Criminal Code of 1961
  # when it's one of that code's, and a link to the chart without it, which the block builds from the paragraph.
  def paragraphs_subtitle_list(paragraphs)
    items = paragraphs.map { |value| paragraphs_subtitle_item(value, yield(value)) }

    tag.div(class: 'mt-3') do
      tag.small { tag.ul(safe_join(items), class: 'list-unstyled ms-3 paragraphs-list') }
    end
  end

  private

  def paragraphs_subtitle_item(value, path)
    badge = old_paragraph_badge if Paragraph.type_of(value) == :old

    tag.li(class: 'mt-1 d-flex') do
      safe_join(
        [
          tag.span(Paragraph.name_of(value), class: 'text-truncate'),
          badge,
          link_to('×', path, class: 'flex-fill ms-2 cancel')
        ]
      )
    end
  end

  def old_paragraph_badge
    tag.span(class: 'ms-2 facet-tag') do
      tooltip_tag(t('statistics.index.search.paragraph.old.badge'), t('statistics.index.search.paragraph.old.title'))
    end
  end
end
