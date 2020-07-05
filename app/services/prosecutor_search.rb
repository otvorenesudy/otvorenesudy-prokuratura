class ProsecutorSearch
  attr_reader :search

  def initialize(params)
    @search =
      Search.new(Prosecutor, params: params, filters: { type: TypeFilter, sort: SortFilter, query: QueryFilter })
  end

  delegate :all, to: :search
  delegate :paginated, to: :search
  delegate :facets_for, to: :search
  delegate :params, to: :search

  class QueryFilter
    def self.filter(relation, params)
      return relation if params[:q].blank?

      columns = %i[name office declarations]
      order = params[:sort] == 'relevancy' && params[:order].in?(%w[asc desc]) ? params[:order].to_sym : nil

      ::QueryFilter.filter(relation, params, columns: columns, order: order)
    end
  end

  class TypeFilter
    def self.filter(relation, params)
      return relation if params[:type].blank?

      relation.joins(:offices).where(offices: { type: params[:type] }).distinct
    end

    def self.facets(relation, suggest:)
      relation.joins(:offices).group('offices.type').count.each.with_object({}) do |(value, count), hash|
        hash[Office.types.key(value)] = count
      end
    end
  end

  class SortFilter
    def self.filter(relation, params)
      order = params[:order] || 'asc'

      return relation unless order.in?(%w[asc desc])

      return relation.reorder(type: order == 'asc' ? 'desc' : 'asc') if params[:sort] == 'type'
      return relation.reorder(name: order) if params[:sort] == 'name'

      relation.order(id: order)
    end
  end
end
