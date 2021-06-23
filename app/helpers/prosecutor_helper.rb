module ProsecutorHelper
  def prosecutors_path(*args, &block)
    path = super(*args, &block)

    args.any? && args[0].any? ? "#{path}#facets" : path
  end

  def prosecutor_activity_icon_tag(type, options = {})
    n, c, t =
      case type
      when 'fixed'
        %w[check text-success prosecutors.appointment.fixed]
      when 'temporary'
        %w[check text-warning prosecutors.appointment.temporary]
      when 'inactive'
        %w[times text-danger prosecutors.appointment.inactive]
      end

    i18n_options = options.delete(:i18n) || {}
    options = options.merge class: Array.wrap(options[:class]).unshift("d-inline #{c}")
    options = options.merge placement: options.delete(:placement) || 'top'

    tooltip_tag icon_tag(n, size: options.delete(:size)), I18n.t(t, i18n_options), options
  end

  def prosecutor_declaration_date(value)
    I18n.l(Time.parse(value).to_date)
  rescue StandardError
    value
  end
end
