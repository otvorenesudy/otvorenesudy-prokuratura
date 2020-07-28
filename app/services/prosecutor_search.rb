class ProsecutorSearch
  attr_reader :search

  def initialize(params)
    @search =
      Search.new(
        Prosecutor,
        params: params,
        filters: { type: TypeFilter, city: CityFilter, office: OfficeFilter, sort: SortFilter, query: QueryFilter }
      )
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
      relation.joins(:offices).group('offices.type').distinct.count.each.with_object({}) do |(value, count), hash|
        hash[Office.types.key(value)] = count
      end
    end
  end

  class CityFilter
    def self.filter(relation, params)
      return relation if params[:city].blank?

      relation.joins(:offices).where(offices: { city: params[:city] }).distinct
    end

    def self.facets(relation, suggest:)
      relation = ::QueryFilter.filter(relation, { q: suggest }, columns: %i[city])

      Prosecutor.from(
        relation.joins(:offices).except(:distinct).select(
          'DISTINCT ON (prosecutors.id, offices.city) prosecutors.id AS id, offices.city AS city'
        ),
        :prosecutors
      ).reorder(city: :asc).group(:city).count
    end
  end

  class OfficeFilter
    def self.filter(relation, params)
      return relation if params[:office_id].blank?

      relation.joins(:offices).where(offices: { name: params[:office] }).distinct
    end

    def self.facets(relation, suggest:)
      relation = ::QueryFilter.filter(relation, { q: suggest }, columns: %i[office])

      Prosecutor.from(
        relation.joins(:offices).except(:distinct).select(
          'DISTINCT ON (prosecutors.id, offices.name) prosecutors.id AS id, offices.name AS office'
        ),
        :prosecutors
      ).reorder(office: :asc).group(:office).count
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
