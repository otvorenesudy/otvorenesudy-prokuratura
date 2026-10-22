# frozen_string_literal: true

class ProsecutorsController < ApplicationController
  def index
    @search = ProsecutorSearch.new(index_params)

    @search.params[:sort] = nil if @search.params[:sort] == 'relevancy' && @search.params[:q].blank?
  end

  def show
    @prosecutor = Prosecutor.find(params.expect(:id))
    @tab = show_params[:tab]
    @paragraphs = Paragraph.where(value: show_params[:paragraph]) if params[:paragraph].present?
    @decrees = @prosecutor.decrees
    @decrees = @decrees.where(paragraph: @paragraphs) if @paragraphs.present?
    return unless @prosecutor.declarations

    @declarations =
      @prosecutor.declarations.map!(&:deep_symbolize_keys).sort_by { |e| e[:year] }.reverse
  end

  def suggest
    return head :not_found unless suggest_params[:facet].in?(%w[city office paragraph])

    @search = ProsecutorSearch.new(index_params)
    facet = suggest_params[:facet]

    render partial: "#{facet}_results", locals: {
      values: @search.facets_for(facet, suggest: suggest_params[:suggest]),
      params: @search.params
    }
  end

  def export
    render plain: DeclarationsExport.to_csv
  end

  private

  helper_method :index_params, :show_params

  def index_params
    params.permit(:page, :sort, :order, :q, type: [], city: [], office: [], decrees_count: [], paragraph: [])
  end

  def show_params
    params.permit(:tab, paragraph: [])
  end

  def suggest_params
    params.permit(:facet, :suggest)
  end
end
