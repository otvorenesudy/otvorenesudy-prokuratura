class StatisticSearch
  attr_reader :search, :params, :current_statistic_metric, :default_statistic_metric, :current_statistic_paragraphs

  def initialize(params)
    @params = params
    @default_statistic_metric =
      params[:paragraph_old].present? || params[:paragraph_new].present? ? :_sentence_all : :judged_all # TODO: different default than :judge_all
    @current_statistic_metric = params[:metric]&.first || @default_statistic_metric
    @current_statistic_paragraphs = [params[:paragraph_old], params[:paragraph_new]].flatten.compact
    @search =
      Search.new(
        Statistic.all,
        params: params,
        filters: {
          year: YearFilter,
          office: OfficeFilter,
          office_type: OfficeTypeFilter,
          metric: MetricFilter,
          paragraph: ParagraphFilter,
          paragraph_old: ParagraphFacet.new(:old),
          paragraph_new: ParagraphFacet.new(:new)
        }
      )
  end

  delegate :all, to: :search
  delegate :params, to: :search
  delegate :facets_for, to: :search

  def data
    relation = current

    sums =
      relation.where(paragraph: nil).joins(:office).order(:year, :'offices.name').group(:year, :'offices.name').sum(
        :count
      )

    sums_by_paragraphs =
      relation.joins(:office).where.not(paragraph: nil).group(:year, :'offices.name').order(:year, :'offices.name').sum(
        :count
      )

    all = sums_by_paragraphs.merge(sums)
    years = all.keys.map(&:first).uniq.sort
    groupped =
      all.each.with_object({}) do |((year, office), count), hash|
        hash[office] = (hash[office] || {}).merge(year => count)
      end

    if params[:office].blank?
      groupped =
        groupped.each.with_object({}) do |(office, years), hash|
          years.each do |year, count|
            hash[office] = (hash[office] || {}).merge(year => count)

            hash[I18n.t('statistics.index.search.office.all')] ||= {}
            hash[I18n.t('statistics.index.search.office.all')][year] =
              (hash[I18n.t('statistics.index.search.office.all')][year] || 0) + count
          end
        end
    end

    { years: years, data: groupped.map { |office, values| { name: office, data: years.map { |e| values[e] } } } }
  end

  def current
    params[:metric].present? ? @search.all : MetricFilter.filter(@search.all, { metric: [default_statistic_metric] })
  end

  def has_metric?(value)
    @metrics ||= @search.all.pluck(Arel.sql('DISTINCT statistics.metric')).map(&:to_sym)

    value.in?(@metrics)
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

  class MetricFilter
    def self.filter(relation, params)
      return relation unless params[:metric].present?

      metric = params[:metric].first
      metric = metric.match(/^_(sentence|closure)/) ? Statistic::GROUPS[$1.to_sym] : metric

      relation = relation.where(metric: metric)
    end
  end

  class ParagraphFilter
    def self.filter(relation, params)
      return relation if params[:paragraph_old].blank? && params[:paragraph_new].blank?

      paragraphs = (params[:paragraph_old] || []) + (params[:paragraph_new] || [])

      relation.where(paragraph: paragraphs)
    end
  end

  class ParagraphFacet
    attr_accessor :type

    def initialize(type)
      @type = type
    end

    def except
      %i[paragraph_old paragraph_new paragraph]
    end

    def facets(relation, suggest:)
      paragraphs = ::QueryFilter.filter(Paragraph.where(type: type).all, { q: suggest }, columns: %i[name])
      order = paragraphs.pluck(:value)

      relation.where(paragraph: paragraphs.select(:value)).group(:paragraph).count.map do |value, count|
        [value, count]
      end.sort_by { |(name, _)| order.index(name) }.to_h
    end
  end
end
