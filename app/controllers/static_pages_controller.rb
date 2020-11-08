class StaticPagesController < ApplicationController
  def show
    @slug = params[:slug]

    return head 404 unless @slug.in?('about contact copyright faq feedback privacy tos')

    name = @slug.gsub(/-/, '_')

    @title = translate "static_pages.#{name}", default: ''
    @template = "static_pages/#{name}"

    begin
      render
    rescue ActionView::ActionViewError => e
      exceptions = [e, e.respond_to?(:original_exception) ? e.original_exception : nil].compact
      types = exceptions.map(&:class)

      if types.include?(ActionView::MissingTemplate) || types.include?(ArgumentError)
        raise ActionController::RoutingError.new nil
      end

      raise e
    end
  end
end
