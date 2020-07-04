module TranslationHelper
  def translate_with_count(count, key, options = {})
    I18n.t("counts.#{key}", count: count < 5 ? count : number_with_delimiter(count, options))
  end
end
