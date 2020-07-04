class OfficeSearch
  attr_reader :search

  def initialize(params)
    @search =
      Search.new(
        Office.order(id: :asc),
        params: params,
        filters: { type: TypeFilter, city: CityFilter, prosecutors_count: ProsecutorsCountFilter, query: QueryFilter }
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

  class ProsecutorsCountFilter
    def self.filter(relation, params)
      return relation if params[:prosecutors_count].blank?

      values = params[:prosecutors_count].map { |count| ActiveRecord::Base.connection.quote(count) }

      relation.where(
        id:
          relation.joins(:employees).merge(Employee.as_prosecutor).group(:id).having(
            "count(*) :: text = ANY(ARRAY[#{values.join(', ')}])"
          ).select(:id).distinct
      )
    end

    def self.facets(relation, suggest:)
      Office.group(:count).order(count: :asc).from(
        relation.joins(:employees).merge(Employee.as_prosecutor).group(:id).select('count(*) :: text as count'),
        :offices
      ).count
    end
  end
end
