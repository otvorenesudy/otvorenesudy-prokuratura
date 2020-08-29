module TextHelper
  def trim(text, length: 30, separator: ' ', ommision: '…')
    return text unless text.size > length

    content_tag(:span, 'data-toggle' => :tooltip, title: text) do
      truncate(text, length: length, separator: separator, omission: ommision)
    end
  end
end
