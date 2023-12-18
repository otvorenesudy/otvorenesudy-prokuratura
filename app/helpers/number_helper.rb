module NumberHelper
  def range_with_count(value, term_for_count:)
    _, min, max = *value.to_s.match(/\A(\d+)..(\d+)\z/)

    "
      #{[min, max].join(" #{I18n.t('numbers.range.separator')} ")} 
      #{I18n.t(term_for_count, count: max.to_i)}
    "
  end

  def number_to_abbreviation(number)
    number_to_human(
      number,
      format: '%n%u',
      precision: 1,
      significant: false,
      units: {
        thousand: 'K',
        million: 'M',
        billion: 'B'
      }
    )
  end
end
