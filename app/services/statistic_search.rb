class StatisticSearch
  attr_reader :search

  def initialize(params)
    @search =
      Search.new(
        Statistic.all,
        params: params, filters: { year: YearFilter, office: OfficeFilter, accused: AccusedFilter }
      )
  end

  delegate :all, to: :search
  delegate :paginated, to: :search
  delegate :facets_for, to: :search
  delegate :params, to: :search

  class YearFilter
    def self.filter(relation, params)
      return relation if params[:year].blank?

      relation.where(year: params[:year])
    end

    def self.facets(relation, suggest:)
      relation.group(:year).reorder(year: :desc).count
    end
  end

  class OfficeFilter
    def self.filter(relation, params)
      return relation if params[:office_id].blank?

      relation.joins(:office).where(offices: { name: params[:office] })
    end

    def self.facets(relation, suggest:)
      offices = ::QueryFilter.filter(Office.all, { q: suggest }, columns: %i[name])

      relation.where(office: offices).joins(:office).reorder('offices.name': :asc).group('offices.name').count.first(5)
        .to_h
    end
  end

  class AccusedFilter
    def self.facets(relation, suggest:)
      relation.where('statistics.filters && ARRAY[?] :: varchar[]', Statistic::GROUPS[:accused]).group(
        'statistics.filters[1]'
      ).count.sort_by { |e, _| Statistic::GROUPS[:accused].index(e.to_sym) }.to_h
    end
  end
end
