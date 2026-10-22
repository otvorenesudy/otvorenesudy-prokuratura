# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def show
    @slug = show_params[:slug]

    return head :not_found unless @slug.in?(%w[about contact copyright faq feedback privacy tos])

    name = "_#{@slug.tr('-', '_')}"

    @title = translate "static_pages.#{name}", default: ''

    render "static_pages/#{name}"
  end

  private

  def show_params
    params.permit(:slug)
  end
end
