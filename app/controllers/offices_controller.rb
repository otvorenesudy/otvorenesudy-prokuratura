class OfficesController < ApplicationController
  def index
    @offices = Office.order(id: :asc)
  end

  private

  def index_params
    params.permit(:page)
  end
end
