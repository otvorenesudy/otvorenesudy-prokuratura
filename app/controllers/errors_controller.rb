class ErrorsController < ApplicationController
  def show
    @code = params[:code].in?(%w[400 404 500]) ? params[:code] : 500
    @title = I18n.t("errors.#{@code}.title")
    @description = I18n.t("errors.#{@code}.description")
  end
end
