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

  class QueryFilter
    def self.filter(relation, params)
      return relation unless params[:q]

      query = ActiveRecord::Base.connection.quote(params[:q])

      columns = %i[offices.name offices.address offices.city]

      relation.where(
        columns.map do |column|
          "
            lower(#{column}) LIKE lower(:like) OR
            similarity(lower(#{column}), lower(:similarity)) > 0.3
          "
        end.join(' OR '),
        like: "%#{params[:q]}%", similarity: params[:q]
      ).reorder(columns.map { |column| "similarity(lower(#{column}), lower(#{query}))" }.join(' + ') + ' DESC')
    end
  end

  class TypeFilter
    def self.filter(relation, params)
      return relation unless params[:type]

      relation.where(type: params[:type])
    end

    def self.facets(relation)
      relation.reorder(type: :asc).group(:type).count
    end
  end

  class CityFilter
    def self.filter(relation, params)
      return relation unless params[:city]

      relation.where(city: params[:city])
    end

    def self.facets(relation)
      relation.reorder(city: :asc).group(:city).count
    end
  end
end
