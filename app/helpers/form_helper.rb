module FormHelper
  def form_params(params)
    params.each_pair do |name, value|
      next if value.nil?

      if value.is_a? Array
        value.each { |v| yield "#{name}[]", v }
      else
        yield name, value
      end
    end
  end
end
