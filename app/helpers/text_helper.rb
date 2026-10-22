# frozen_string_literal: true

module TextHelper
  # The text cut to `length` characters, the whole of it in a tooltip.
  def trim(text, length: 27, omission: '…')
    return text unless text && text.size > length

    tag.span(truncate(text, length:, omission:), title: text, data: { controller: 'tooltip', bs_title: text })
  end
end
