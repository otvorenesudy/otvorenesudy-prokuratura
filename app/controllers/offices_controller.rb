class OfficesController < ApplicationController
  def index
    @search = OfficeSearch.new(index_params)

    @search.params[:sort] = nil if @search.params[:sort] == 'relevancy' && @search.params[:q].blank?
  end

  def show
    @office = Office.find(params[:id])
    @tab = show_params[:tab]
    @paragraphs = Paragraph.where(value: show_params[:paragraph]) if params[:paragraph].present?
    @decrees = @office.decrees
    @decrees = @decrees.where(paragraph: @paragraphs) if @paragraphs.present?
    @registry = @office.registry.deep_symbolize_keys
  end

  def suggest
    return head 404 unless suggest_params[:facet].in?(%w[city paragraph])

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

  helper_method :index_params, :show_params

  def index_params
    params.permit(:page, :sort, :order, :q, type: [], city: [], prosecutors_count: [], decrees_count: [], paragraph: [])
  end

  def show_params
    params.permit(:tab, paragraph: [])
  end

  def suggest_params
    params.permit(:facet, :suggest)
  end
end
