module TagHelper
  def help_tag(key, options = {})
    options = options.merge class: 'd-inline text-info', trigger: 'hover'
    title = t "#{key}.title"
    options[:title] = title if title.present?
    popover_tag icon_tag('question', size: 12),
                t("#{key}.content", options[:content_translation_options] || {}),
                options
  end

  def popover_tag(name, content, options = {})
    options[:placement] ||= 'top'
    data = options.extract!(*%i[delay placement trigger]).select { |_, v| v }
    options.deep_merge! data: data.merge(content: content, toggle: 'popover'), tabindex: -1
    link_to name, '#', options
  end

  def span_tag(*args, &block)
    content_tag :span, *args, &block
  end

  def time_tag(date_or_time, *args, &block)
    options = args.extract_options!
    content = localize date_or_time, options
    content = block.call content if block_given?
    super date_or_time, content, options
  end
end
