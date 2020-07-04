class OfficeSearch
  attr_reader :search

  def initialize(params)
    @search =
      Search.new(
        Office.order(id: :asc),
        params: params, filters: { type: TypeFilter, city: CityFilter, query: QueryFilter }
      )
  end

  delegate :all, to: :search
  delegate :paginated, to: :search
  delegate :facets_for, to: :search
  delegate :params, to: :search

  class QueryFilter
    def self.filter(relation, params)
      return relation if params[:q].blank?

      columns = %i[name address city employee]

      ::QueryFilter.filter(relation, params, columns: columns)
    end
  end

  class TypeFilter
    def self.filter(relation, params)
      return relation if params[:type].blank?

      relation.where(type: params[:type])
    end

    def self.facets(relation, suggest:)
      relation.reorder(type: :asc).group(:type).count
    end
  end

  class CityFilter
    def self.filter(relation, params)
      return relation if params[:city].blank?

      relation.where(city: params[:city])
    end

    def self.facets(relation, suggest:)
      relation = ::QueryFilter.filter(relation, { q: suggest }, columns: %i[city])

      relation.reorder(city: :asc).group(:city).count
    end
  end
end
