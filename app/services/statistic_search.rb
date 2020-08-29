class StatisticSearch
  attr_reader :search

  def initialize(params)
    @search = Search.new(Statistic.all, params: params, filters: { year: YearFilter })
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
      relation = ::QueryFilter.filter(relation, { q: suggest }, columns: %i[office])

      Prosecutor.from(
        relation.joins(:offices).except(:distinct).select(
          'DISTINCT ON (prosecutors.id, offices.name) prosecutors.id AS id, offices.name AS office'
        ),
        :prosecutors
      ).reorder(office: :asc).group(:office).count
    end
  end
end
