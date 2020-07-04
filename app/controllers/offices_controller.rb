class OfficesController < ApplicationController
  def index
    @search = OfficeSearch.new(index_params)
  end

  private

  helper_method :index_params

  def index_params
    params.permit(:page, :order, :q, type: [], city: [])
  end
end
