class StatisticSearch
  attr_reader :search, :params

  def initialize(params)
    @params = params

    @search =
      Search.new(
        Statistic.all,
        params: params, filters: { year: YearFilter, office: OfficeFilter, filters: FiltersFilter }
      )
  end

  delegate :all, to: :search
  delegate :params, to: :search
  delegate :facets_for, to: :search

  def data
    sums =
      @search.all.where('array_length(statistics.filters, 1) = 1').joins(:office).order(:year, :'offices.name').group(
        :year,
        :'offices.name'
      ).sum(:count)

    sums_by_paragraphs =
      @search.all.joins(:office).where('array_length(statistics.filters, 1) > 1').group(:year, :'offices.name').order(
        :year,
        :'offices.name'
      ).sum(:count)

    sums_by_paragraphs.merge(sums).group_by { |(_, office), _| office }.map do |office, data|
      data = data.sort_by { |e| e[0][0] }

      { name: office, data: data.map { |e| e[1] }, years: data.map { |e| e[0][0] } }
    end
  end

  def has_statistic_filter?(value)
    @statistic_filters ||= @search.all.pluck(Arel.sql('DISTINCT statistics.filters[1] AS filter')).map(&:to_sym)

    value.in?(@statistic_filters)
  end

  class YearFilter
    def self.filter(relation, params)
      return relation if params[:year].blank?

      relation.where(year: params[:year])
    end

    def self.facets(relation, suggest:)
      relation.reorder(year: :desc).group(:year).count
    end
  end

  class OfficeFilter
    def self.filter(relation, params)
      return relation if params[:office].blank?

      relation.joins(:office).where(offices: { name: params[:office] })
    end

    def self.facets(relation, suggest:)
      offices = ::QueryFilter.filter(Office.all, { q: suggest }, columns: %i[name])

      relation.where(office: offices).joins(:office).reorder('offices.name': :asc).group('offices.name').count
    end
  end

  class FiltersFilter
    def self.filter(relation, params)
      return relation unless params[:filters].present?

      relation = relation.where('statistics.filters[1] = ?', params[:filters][0])

      return relation unless params[:filters][1]

      relation.where('statistics.filters[2] = ?', params[:filters][1])
    end
  end
end
