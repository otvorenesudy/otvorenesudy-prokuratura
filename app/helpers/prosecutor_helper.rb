# frozen_string_literal: true

module ProsecutorHelper
  # The icon, its color and the explanation of each kind of appointment.
  ACTIVITY_ICONS = {
    'fixed' => %w[check text-success prosecutors.appointment.fixed],
    'temporary' => %w[check text-warning prosecutors.appointment.temporary],
    'inactive' => %w[times text-danger prosecutors.appointment.inactive]
  }.freeze

  def prosecutors_path(*args, &)
    path = super

    args.any? && args[0].any? ? "#{path}#facets" : path
  end

  def prosecutor_activity_icon_tag(type, options = {})
    icon, color, key = ACTIVITY_ICONS.fetch(type)

    i18n_options = options.delete(:i18n) || {}
    options = options.merge class: Array.wrap(options[:class]).unshift("d-inline #{color}")
    options = options.merge placement: options.delete(:placement) || 'top'

    tooltip_tag icon_tag(icon, size: options.delete(:size)), I18n.t(key, **i18n_options), options
  end

  def prosecutor_declaration_date(value)
    I18n.l(Time.zone.parse(value).to_date)
  rescue StandardError
    value
  end
end
