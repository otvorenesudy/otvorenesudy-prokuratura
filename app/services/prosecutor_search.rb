class ProsecutorSearch
  attr_reader :search

  def initialize(params)
    @search =
      Search.new(
        Prosecutor,
        params: params,
        filters: {
          type: TypeFilter,
          city: CityFilter,
          office: OfficeFilter,
          sort: SortFilter,
          query: QueryFilter
        }
      )
  end

  delegate :all, to: :search
  delegate :paginated, to: :search
  delegate :facets_for, to: :search
  delegate :params, to: :search

  class QueryFilter
    def self.filter(relation, params)
      return relation if params[:q].blank?

      columns = %i[name office]
      order = params[:sort] == 'relevancy' && params[:order].in?(%w[asc desc]) ? params[:order].to_sym : nil

      ::QueryFilter.filter(relation, params, columns: columns)
    end
  end

  class TypeFilter
    def self.filter(relation, params)
      return relation if params[:type].blank?

      relation.joins(:offices).where(offices: { type: params[:type] }).distinct
    end

    def self.facets(relation, suggest:)
      relation
        .joins(:offices)
        .group('offices.type')
        .distinct
        .count
        .each
        .with_object({}) { |(value, count), hash| hash[Office.types.key(value)] = count }
    end
  end

  class CityFilter
    def self.filter(relation, params)
      return relation if params[:city].blank?

      relation.joins(:offices).where(offices: { city: params[:city] }).distinct
    end

    def self.facets(relation, suggest:)
      offices = ::QueryFilter.filter(Office.all, { q: suggest }, columns: %i[city])

      relation.joins(:offices).merge(offices).reorder('offices.city': :asc).group('offices.city').count
    end
  end

  class OfficeFilter
    def self.filter(relation, params)
      return relation if params[:office].blank?

      relation.joins(:offices).where(offices: { name: params[:office] }).distinct
    end

    def self.facets(relation, suggest:)
      offices = ::QueryFilter.filter(Office.all, { q: suggest }, columns: %i[name])

      relation.joins(:offices).merge(offices).reorder('offices.name': :asc).group('offices.name').count
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
