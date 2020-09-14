module SearchHelper
  def search_params(params, other, replace: false)
    params = params.to_h.with_indifferent_access

    other.each do |key, value|
      next params[key] = nil if value.nil?

      value = value.to_s
      values = [*params[key]].compact

      next params[key] = [value] if replace

      params[key] = value.in?(values) ? values - [value] : [*values, value]
    end

    params
  end

  def search_param?(params, key, value)
    return unless params[key]

    value = value.to_s

    params[key] == value || value.in?(params[key])
  end
end
