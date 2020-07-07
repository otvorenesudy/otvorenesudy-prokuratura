module NumberHelper
  def range_with_count(value, term_for_count:)
    _, min, max = *value.to_s.match(/\A(\d+)..(\d+)\z/)

    "
      #{[min, max].join(" #{I18n.t('numbers.range.separator')} ")} 
      #{I18n.t(term_for_count, count: max.to_i)}
    "
  end
end
