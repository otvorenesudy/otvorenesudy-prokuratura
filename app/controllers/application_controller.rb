class ApplicationController < ActionController::Base
  before_action { set_locale(params[:l] || I18n.default_locale) }

  protected

  private

  def set_locale(value)
    I18n.locale = value
  rescue I18n::InvalidLocale
    redirect_to :root
  end
end
