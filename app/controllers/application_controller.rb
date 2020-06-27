class ApplicationController < ActionController::Base
  before_action { set_locale(params[:l] || I18n.default_locale) }

  protected

  def default_url_options
    { l: I18n.locale, only_path: true }
  end

  private

  def set_locale(value)
    I18n.locale = value
  rescue I18n::InvalidLocale
    redirect_to :root
  end
end
