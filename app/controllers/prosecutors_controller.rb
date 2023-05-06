class ProsecutorsController < ApplicationController
  def index
    @search = ProsecutorSearch.new(index_params)

    @search.params[:sort] = nil if @search.params[:sort] == 'relevancy' && @search.params[:q].blank?
  end

  def show
    @prosecutor = Prosecutor.find(params[:id])

    @declarations = @prosecutor.declarations.reverse.map!(&:deep_symbolize_keys) if @prosecutor.declarations
  end

  def suggest
    return head 404 unless suggest_params[:facet].in?(%w[city office])

    @search = ProsecutorSearch.new(index_params)

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

  def export
    csv =
      CSV.generate do |csv|
        csv << [
          'ID',
          'Name',
          'Current Office',
          'Temporary Office',
          'Declaration Year',
          'Declaration Category',
          'Description',
          'Acquisition Date',
          'Aquisition Reason',
          'Price/Value',
          'Procurement Price/Value'
        ]

        Prosecutor.find_each.map do |prosecutor|
          attributes = [
            prosecutor.id,
            prosecutor.name,
            prosecutor.appointments.fixed.first&.office&.name,
            prosecutor.appointments.temporary.first&.office&.name
          ]

          prosecutor.declarations&.each do |declaration|
            declaration['lists'].each do |list|
              list['items'].each do |item|
                csv << [
                  *attributes,
                  declaration['year'],
                  list['category'],
                  *item.values_at('description', 'acquisition_date', 'acquisition_reason', 'price', 'procurement_price')
                ]
              end
            end

            declaration['incomes']&.each do |income|
              csv << [
                *attributes,
                declaration['year'],
                'Príjmy',
                income['description'],
                nil,
                nil,
                nil,
                income['value'],
                nil
              ]
            end

            declaration['statements'].each do |statement|
              csv << [*attributes, declaration['year'], 'Vyhlásenia', statement, nil, nil, nil, nil, nil]
            end
          end
        end
      end

    render inline: csv
  end

  private

  helper_method :index_params

  def index_params
    params.permit(:page, :sort, :order, :q, type: [], city: [], office: [], decrees_count: [])
  end

  def suggest_params
    params.permit(:facet, :suggest)
  end
end
