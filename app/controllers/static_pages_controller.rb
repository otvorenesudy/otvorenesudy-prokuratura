class StaticPagesController < ApplicationController
  def show
    @slug = show_params[:slug]

    return head 404 unless @slug.in?(%w[about contact copyright faq feedback privacy tos])

    name = "_#{@slug.gsub(/-/, '_')}"

    raise ActionController::RoutingError.new nil unless lookup_context.template_exists?(name, 'static_pages')

    @title = translate "static_pages.#{name}", default: ''

    render "static_pages/#{name}"
  end

  private

  def show_params
    params.permit(:slug)
  end
end
