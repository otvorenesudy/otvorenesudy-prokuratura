class OfficesController < ApplicationController
  def index
    @search = OfficeSearch.new(index_params)
  end

  def suggest
    head 404 unless suggest_params[:facet].in?(%w[city])

    @search = OfficeSearch.new(index_params)

    render json: {
             html:
               render_to_string(
                 partial: "#{suggest_params[:facet]}_results",
                 locals: {
                   values: @search.facets_for(suggest_params[:facet], suggest: suggest_params[:suggest]),
                   params: @search.params
                 }
               )
           }
  end

  private

  helper_method :index_params

  def index_params
    params.permit(:page, :order, :q, type: [], city: [])
  end

  def suggest_params
    params.permit(:facet, :suggest)
  end
end
