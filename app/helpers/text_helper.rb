module TextHelper
  def trim(text, length: 27, ommision: '…')
    return text unless text.size > length

    content_tag(:span, 'data-toggle' => :tooltip, title: text) { truncate(text, length: length, omission: ommision) }
  end
end
