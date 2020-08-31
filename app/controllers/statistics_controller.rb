class StatisticsController < ApplicationController
  def index
    @search = StatisticSearch.new(index_params)
    @time = Benchmark.realtime { @data = @search.data } * 1000
  end

  def suggest
    return head 404 unless suggest_params[:facet].in?(%w[office paragraph_old paragraph_new])

    @search = StatisticSearch.new(index_params)

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
    params.permit(year: [], office: [], filters: [], office_type: [], paragraph_old: [], paragraph_new: [])
  end

  def suggest_params
    params.permit(:facet, :suggest)
  end
end
