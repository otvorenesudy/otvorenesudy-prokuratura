module ProsecutorHelper
  def prosecutors_path(*args, &block)
    path = super(*args, &block)

    args.any? && args[0].any? ? "#{path}#facets" : path
  end

  def prosecutor_activity_icon_tag(appointment, options = {})
    n, c, t =
      case appointment.type
      when 'fixed'
        %w[check text-success prosecutors.appointment.fixed]
      when 'temporary'
        %w[check text-warning prosecutors.appointment.temporary]
      end

    options = options.merge class: Array.wrap(options[:class]).unshift("d-inline #{c}")
    options = options.merge placement: options.delete(:placement) || 'top'

    tooltip_tag icon_tag(n, size: options.delete(:size)), t(t), options
  end
end
