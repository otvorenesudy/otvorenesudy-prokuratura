class StatisticsController < ApplicationController
  def index
    @search = StatisticSearch.new(index_params)
  end

  def suggest
    head 404 unless suggest_params[:facet].in?(%w[office])

    @search = StatisticsSearch.new(index_params)

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

  def index_params
    params.permit(year: [])
  end
end
