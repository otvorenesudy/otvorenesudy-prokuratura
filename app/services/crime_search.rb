class CrimeSearch
  attr_reader :search, :params, :current_statistic_metrics, :current_statistic_paragraphs, :default_params

  def initialize(params)
    @default_params = {
      metric: %w[crime_discovered crime_solved crime_additionally_solved persons_all],
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

    @search =
      Search.new(
        Crime.all,
        params: params,
        filters: {
          year: YearFilter,
          metric: MetricFilter,
          paragraph: ParagraphFilter
        }
      )

    @current_statistic_metrics = params[:metric] || @default_params[:metric]
    @current_statistic_paragraphs =
      (params[:paragraph].blank? && params[:metric].blank? ? @default_params : params)[:paragraph]

    normalize_params
  end

  delegate :all, to: :search
  delegate :params, to: :search
  delegate :facets_for, to: :search

  def default_params?
    default_params && current_statistic_metrics == default_params[:metric] &&
      current_statistic_paragraphs == default_params[:paragraph]
  end

  def paragraphs_present?
    current_statistic_paragraphs.present? && current_statistic_paragraphs != %w[_all]
  end

  def monetary_metric_present?
    current_statistic_metrics.include?('crime_denominated_damage')
  end

  def comparison
    params[:comparison] || 'metrics'
  end

  def data
    @data ||=
      begin
        if comparison === 'metrics'
          all = current.group(:metric, :year).sum(:count)
          groupped =
            all
              .each
              .with_object({}) do |((metric, year), count), hash|
                hash[metric] = (hash[metric] || {}).merge(year => count)
              end
        end

        if comparison === 'paragraphs'
          # TODO
        end

        years = all.keys.map(&:last).uniq.sort

        {
          years: years,
          data:
            groupped.map do |metric, values|
              {
                name: metric_to_human(metric),
                group: Crime::GROUPS.find { |group, values| metric.to_sym.in?(values) }[0],
                metric: metric,
                comparison: comparison,
                monetary: metric === 'crime_denominated_damage',
                data: years.map { |e| values[e] }
              }
            end
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
    @metrics ||= search.all.unscope(where: :metric).pluck(Arel.sql('DISTINCT crimes.metric')).map(&:to_sym)

    params[:metric].blank? ? true : value.in?(@metrics)
  end

  private

  def metric_to_human(value)
    group = Crime::GROUPS.find { |group, values| value.to_sym.in?(values) }[0]

    "#{I18n.t("crimes.index.search.#{group}.title")} – #{I18n.t("models.crime.metrics.#{value}")}"
  end

  def normalize_params
    if params[:paragraph].present? && params[:metric].blank?
      params[:metric] = [*@default_params[:metric], 'crime_denominated_damage']
    end

    params.each do |key, value|
      if params[key].present? && '_all'.in?(params[key]) && (params[key].size > 1 || key.in?(%w[paragraph]))
        params[key] -= %w[_all]
      end
    end

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

  class MetricFilter
    def self.filter(relation, params)
      return relation unless params[:metric].present?

      metric = params[:metric]

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
