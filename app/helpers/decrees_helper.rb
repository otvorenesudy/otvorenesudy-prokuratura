module DecreesHelper
  def decrees_download_icon_link(url, options = {})
    n, c, t = %w[arrow-right text-secondary decrees.download]

    i18n_options = options.delete(:i18n) || {}
    options = options.merge class: Array.wrap(options[:class]).unshift("d-inline #{c}")
    options = options.merge placement: options.delete(:placement) || 'top'

    link_to content_tag(:span, options.merge('data-toggle' => :tooltip, :title => I18n.t(t, **i18n_options))) {
              icon_tag(n, size: options.delete(:size))
            },
            url,
            target: '_blank'
  end
end
