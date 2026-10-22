# frozen_string_literal: true

class CrimesController < ApplicationController
  include ChartScreenshot

  def index
    @search = CrimeSearch.new(index_params)
    @data = @search.data
    @count = Rails.cache.fetch('crimes_count', expires_in: 1.day) { Crime.count }
  end

  def suggest
    return head :not_found unless suggest_params[:facet].in?(%w[paragraph])

    @search = CrimeSearch.new(suggest_params)
    facet = suggest_params[:facet]

    render partial: "#{facet}_results", locals: {
      values: @search.facets_for(facet, suggest: suggest_params[:suggest]),
      params: @search.params.merge("#{facet}_suggest" => suggest_params[:suggest])
    }
  end

  def png
    send_chart_screenshot export_crimes_url(index_params),
                          filename: 'otvorena-prokuratura-kriminalita-policia-export.png'
  end

  def export
    response.headers['X-FRAME-OPTIONS'] = 'ALLOWALL'

    index

    render layout: 'export'
  end

  def embed
    index
  end

  private

  helper_method :index_params

  def index_params
    params.permit(:paragraph_suggest, :show_default_paragraphs, year: [], metric: [], paragraph: [])
  end

  def suggest_params
    params.permit(:facet, :suggest)
  end
end
