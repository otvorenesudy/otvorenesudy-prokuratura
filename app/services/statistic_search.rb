class StatisticSearch
  attr_reader :search, :params, :current_statistic_metric, :current_statistic_paragraphs, :default_params

  def initialize(params)
    @params = params

    if params[:paragraph].present? && params[:metric].blank?
      params[:metric] = %i[_sentence_all]
    else
      @default_params = {
        metric: %i[_sentence_all],
        paragraph: [
          '§ 328 [new]',
          '§ 329 [new]',
          '§ 330 [new]',
          '§ 331 [new]',
          '§ 332 [new]',
          '§ 333 [new]',
          '§ 334 [new]',
          '§ 336 [new]',
          '§ 336a [new]',
          '§ 336b [new]',
          '§ 160 [old]',
          '§ 160a [old]',
          '§ 160b [old]',
          '§ 160c [old]',
          '§ 161 [old]',
          '§ 161a [old]',
          '§ 161b [old]',
          '§ 161c [old]',
          '§ 162 [old]'
        ]
      }
    end

    @current_statistic_metric = params[:metric]&.first || @default_params[:metric].first
    @current_statistic_paragraphs =
      (params[:paragraph].blank? && params[:metric].blank? ? @default_params : params)[:paragraph]

    @search =
      Search.new(
        Statistic.all,
        params: params,
        filters: {
          year: YearFilter,
          office: OfficeFilter,
          office_type: OfficeTypeFilter,
          metric: MetricFilter,
          paragraph: ParagraphFilter
        }
      )

    normalize_params
  end

  delegate :all, to: :search
  delegate :params, to: :search
  delegate :facets_for, to: :search

  def default_params?
    default_params && current_statistic_metric == default_params[:metric][0] &&
      current_statistic_paragraphs == default_params[:paragraph]
  end

  def paragraphs_present?
    current_statistic_paragraphs.present? && current_statistic_paragraphs != %w[_all]
  end

  def office_aggregate_key
    @office_aggregate_key ||= I18n.t('statistics.index.search.office.all')
  end

  def comparison
    params[:comparison] || 'global'
  end

  def data
    @data ||=
      begin
        relation = current(except: %i[office office_type])

        sums = relation.where(paragraph: nil).joins(:office).order(:year).group(:year).sum(:count)
        sums_by_paragraphs = relation.joins(:office).where.not(paragraph: nil).group(:year).order(:year).sum(:count)

        all =
          sums_by_paragraphs.merge(sums) do |_, from_paragraphs, from_sums|
            from_sums.present? ? from_sums : from_paragraphs
          end

        years = all.keys
        groupped =
          all
            .each
            .with_object({}) do |(year, count), hash|
              hash[office_aggregate_key] = (hash[office_aggregate_key] || {}).merge(year => count)
            end

        by_office = data_by(years, aggregate: :office)

        if paragraphs_present?
          by_paragraphs =
            data_by(years, aggregate: :paragraph).each do |statistic|
              statistic[:name] = format_paragraph_name_for_chart(statistic[:name])
            end
        end

        {
          years: years,
          data:
            groupped.map do |office, values|
              { name: office, global: true, table: true, data: years.map { |e| values[e] } }
            end + by_office + (by_paragraphs || [])
        }
      end
  end

  def current(except: [])
    if params[:metric].present?
      @search.all(except: except)
    else
      MetricFilter.filter(ParagraphFilter.filter(@search.all(except: except), default_params), default_params)
    end
  end

  def has_metric?(value)
    @metrics ||= search.all.pluck(Arel.sql('DISTINCT statistics.metric')).map(&:to_sym)

    if params[:metric].blank? ||
         (value.match(/\A_(sentence|closure)/) && params[:metric].first.match(/\A_?#{Regexp.last_match(1)}/))
      true
    else
      value.in?(@metrics)
    end
  end

  private

  def data_by(years, aggregate:)
    relation = current
    group = { office: :'offices.name', paragraph: :paragraph }[aggregate]

    sums = relation.where(paragraph: nil).joins(:office).order(:year, group).group(:year, group).sum(:count)

    sums_by_paragraphs =
      relation.joins(:office).where.not(paragraph: nil).group(:year, group).order(:year, group).sum(:count)

    all =
      sums_by_paragraphs.merge(sums) do |_, from_paragraphs, from_sums|
        from_sums.present? ? from_sums : from_paragraphs
      end

    groupped =
      all.each.with_object({}) { |((year, name), count), hash| hash[name] = (hash[name] || {}).merge(year => count) }

    groupped.map do |name, values|
      { name: name, table: aggregate == :office ? true : false, data: years.map { |e| values[e] } }.merge(
        aggregate => true
      )
    end
  end

  def normalize_params
    params.each do |key, value|
      if params[key].present? && '_all'.in?(params[key]) && (params[key].size > 1 || key.in?(%w[paragraph]))
        params[key] -= %w[_all]
      end
    end

    params[:comparison] = nil if current_statistic_paragraphs.blank? && params[:comparison] == 'paragraph'
    params[:show_default_paragraphs] = nil unless default_params?
  end

  def format_paragraph_name_for_chart(value)
    name = Paragraph.name_of(value)
    name += " [#{I18n.t('statistics.index.search.paragraph.old.badge')}]" if Paragraph.type_of(value) == :old

    name
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
      return relation if params[:office].blank? || params[:office] == %w[_all]

      relation.joins(:office).where(offices: { name: params[:office] })
    end

    def self.facets(relation, suggest:)
      if suggest.present?
        offices = ::QueryFilter.filter(Office.all, { q: suggest }, columns: %i[name])
        relation = relation.where(office: offices)
      end

      relation.joins(:office).reorder('offices.name': :asc).group('offices.name').count
    end
  end

  class OfficeTypeFilter
    def self.filter(relation, params)
      return relation if params[:office_type].blank?

      relation.joins(:office).where(offices: { type: params[:office_type] })
    end

    def self.facets(relation, suggest:)
      relation
        .joins(:office)
        .reorder('offices.type' => :asc)
        .group('offices.type')
        .count
        .each
        .with_object({}) { |(value, count), hash| hash[value] = count }
    end
  end

  class MetricFilter
    def self.filter(relation, params)
      return relation unless params[:metric].present?

      metric = params[:metric].first
      metric = metric.match(/\A_(sentence|closure)/) ? Statistic::GROUPS[Regexp.last_match(1).to_sym] : metric

      relation = relation.where(metric: metric)
    end
  end

  class ParagraphFilter
    def self.filter(relation, params)
      return relation if params[:paragraph].blank?

      relation.where(paragraph: params[:paragraph])
    end

    def self.facets_limit
      nil
    end

    def self.facets(relation, suggest:)
      highlights =
        [
          '§ 145 [new]',
          '§ 199 [new]',
          '§ 212 [new]',
          '§ 326 [new]',
          '§ 363 [new]',
          '§ 144 [new]',
          '§ 221 [new]',
          '§ 326 [new]',
          '§ 345 [new]'
        ].map { |value| ActiveRecord::Base.connection.quote(value) }

      scope =
        Paragraph
          .all
          .order(Arel.sql("array_position(ARRAY[#{highlights.join(',')}] :: text[], value :: text) ASC NULLS LAST"))
          .order(name: :asc)

      paragraphs = ::QueryFilter.filter(scope, { q: suggest }, columns: %i[name]).pluck(:value).to_a

      relation = relation.where(paragraph: paragraphs) if suggest

      relation
        .where.not(paragraph: nil)
        .group(:paragraph)
        .count
        .map { |value, count| [value, count] }
        .select { |(name, _)| paragraphs.include?(name) }
        .sort_by { |(name, _)| paragraphs.index(name) }
        .to_h
    end
  end
end
