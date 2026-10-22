# frozen_string_literal: true

module TagHelper
  # A question mark that explains a term on hover, with the `content:` given.
  def help_tag(options = {})
    content = options.delete(:content)

    popover_tag icon_tag('question', size: 12), content, options.merge(class: 'd-inline text-info', trigger: 'hover')
  end

  def span_tag(*, &)
    content_tag(:span, *, &)
  end
end
