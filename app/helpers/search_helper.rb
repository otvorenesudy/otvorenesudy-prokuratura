module SearchHelper
  def search_params(params, other)
    params = params.to_h

    other.each do |key, value|
      value = value.to_s
      values = [*params[key]].compact

      params[key] = value.in?(values) ? values - [value] : [*values, value]
    end

    params
  end

  def search_params?(params, key, value)
    return unless params[key]

    value = value.to_s

    params[key] == value || value.in?(params[key])
  end
end
