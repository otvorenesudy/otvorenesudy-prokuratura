class OfficeSearch
  attr_reader :search

  def initialize(params)
    @search =
      Search.new(
        Office.active.all,
        params: params,
        filters: {
          query: QueryFilter,
          type: TypeFilter,
          city: CityFilter,
          prosecutors_count: ProsecutorsCountFilter,
          decrees_count:
            Search::DecreesCountFilter.new(
              [1..50, 51..200, 201..500, 501..1000, 1001..1500, 1501..2000, 2001..Office.maximum(:decrees_count)]
            ),
          sort: SortFilter
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

      ranges =
        params[:prosecutors_count].map do |value|
          _, min, max = *value.match(/\A(\d+)\.\.(\d+)\z/)

          "#{ActiveRecord::Base.connection.quote("[#{min}, #{max}]")} :: int4range"
        end

      relation.where(
        id:
          relation
            .joins(:appointments)
            .group(:id)
            .having(ranges.map { |range| "#{range} @> count(*) :: int" })
            .select(:id)
      )
    end

    def self.facets(relation, suggest:)
      buckets = [1..5, 6..10, 11..20, 21..30, 31..Appointment.group(:office_id).order('count(*) DESC').count.first[1]]

      facets =
        Office
          .group(:prosecutors_count)
          .order(prosecutors_count: :asc)
          .from(relation.joins(:appointments).group(:id).select('count(*) as prosecutors_count'), :offices)
          .count

      buckets.map { |range, value| [range.to_s, facets.values_at(*range.to_a).compact.sum] }.to_h
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
