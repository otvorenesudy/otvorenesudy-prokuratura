class OfficesController < ApplicationController
  def index
    @search = OfficeSearch.new(index_params)

    @search.params[:sort] = nil if @search.params[:sort] == 'relevancy' && @search.params[:q].blank?
  end

  def show
    @office = Office.active.find(params[:id])
    @registry = @office.registry.deep_symbolize_keys
  end

  def suggest
    head 404 unless suggest_params[:facet].in?(%w[city])

    @search = OfficeSearch.new(index_params)

    render(
      json: {
        html:
          render_to_string(
            partial: "#{suggest_params[:facet]}_results",
            locals: {
              values: @search.facets_for(suggest_params[:facet], suggest: suggest_params[:suggest]),
              params: @search.params
            }
          )
      }
    )
  end

  private

  helper_method :index_params

  def index_params
    params.permit(:page, :sort, :order, :q, type: [], city: [], prosecutors_count: [])
  end

  def suggest_params
    params.permit(:facet, :suggest)
  end
end
