# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action { switch_locale(locale_params[:l] || I18n.default_locale) }

  protected

  def default_url_options
    { l: I18n.locale }
  end

  private

  def switch_locale(value)
    I18n.locale = value
  rescue I18n::InvalidLocale
    redirect_to :root
  end

  def locale_params
    params.permit(:l)
  end
end
