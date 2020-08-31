class StatisticSearch
  attr_reader :search, :params, :current_statistic_filters, :default_statistic_filter

  def initialize(params)
    @params = params
    @default_statistic_filter = :judged_all
    @current_statistic_filters = params[:filters] || [@default_statistic_filter]
    @search =
      Search.new(
        Statistic.all,
        params: params,
        filters: { year: YearFilter, office: OfficeFilter, office_type: OfficeTypeFilter, filters: FiltersFilter }
      )
  end

  delegate :all, to: :search
  delegate :params, to: :search
  delegate :facets_for, to: :search

  def data
    relation = current

    sums =
      relation.where('array_length(statistics.filters, 1) = 1').joins(:office).order(:year, :'offices.name').group(
        :year,
        :'offices.name'
      ).sum(:count)

    sums_by_paragraphs =
      relation.joins(:office).where('array_length(statistics.filters, 1) > 1').group(:year, :'offices.name').order(
        :year,
        :'offices.name'
      ).sum(:count)

    all = sums_by_paragraphs.merge(sums)
    years = all.keys.map(&:first).uniq.sort
    groupped =
      all.each.with_object({}) do |((year, office), count), hash|
        hash[office] ||= {}
        hash[office][year] = count
      end

    { years: years, data: groupped.map { |office, values| { name: office, data: years.map { |e| values[e] } } } }
  end

  def current
    params[:filters].present? ? @search.all : @search.all.where('statistics.filters[1] = ?', default_statistic_filter)
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

  class OfficeTypeFilter
    def self.filter(relation, params)
      return relation if params[:office_type].blank?

      relation.joins(:office).where(offices: { type: params[:office_type] })
    end

    def self.facets(relation, suggest:)
      relation.joins(:office).reorder('offices.type' => :asc).group('offices.type').count.each.with_object(
        {}
      ) { |(value, count), hash| hash[Office.types.key(value)] = count }
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
