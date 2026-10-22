# frozen_string_literal: true

# Error pages, rendered through config.exceptions_app (which requests /<code>) in the site's layout and the visitor's
# language, with their status.
class ErrorsController < ApplicationController
  def show
    @code = params.expect(:code).presence_in(%w[400 404 500]) || '500'
    @title = I18n.t("errors.#{@code}.title")
    @description = I18n.t("errors.#{@code}.description")

    render status: @code.to_i, formats: :html
  end
end
