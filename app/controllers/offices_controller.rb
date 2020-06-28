class OfficesController < ApplicationController
  def index
    @offices = Office.order(id: :asc).page(index_params[:page] || 1).per(15)
  end

  private

  helper_method :index_params

  def index_params
    params.permit(:page, :order, :q)
  end
end
