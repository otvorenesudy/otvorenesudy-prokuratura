class StatisticsController < ApplicationController
  def index
    @search = StatisticSearch.new(index_params)
    @time = Benchmark.realtime { @data = @search.data } * 1000
    @count = Rails.cache.fetch('statistics_count', expires_in: 1.day) { Statistic.count }
  end

  def suggest
    return head 404 unless suggest_params[:facet].in?(%w[office paragraph])

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
    params.permit(year: [], office: [], metric: [], office_type: [], paragraph: [])
  end

  def suggest_params
    params.permit(:facet, :suggest)
  end
end
