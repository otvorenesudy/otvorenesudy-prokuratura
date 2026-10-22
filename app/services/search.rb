# frozen_string_literal: true

class Search
  attr_reader :repository, :filters, :params

  def initialize(repository, params:, filters:)
    @repository = repository
    @params = params.to_h.with_indifferent_access
    @filters = filters.freeze
  end

  def all(except: [])
    except = [*except].map(&:to_sym)

    filters
      .reject { |(key, _)| key.to_sym.in?(except) }
      .inject(repository) { |relation, (_, filter)| filter.filter(relation, params) }
  end

  def paginated
    all.page(params[:page] || 1).per(15)
  end

  def facets_for(key, suggest: nil, limit: nil, selected_first: false)
    key = key.to_sym
    all = facet_counts(key, suggest || params["#{key}_suggest"])
    limit ||= filters[key].respond_to?(:facets_limit) ? filters[key].facets_limit : 10
    facets = limit ? all.first(limit).to_h : all

    return facets if params[key].blank? || suggest.present?

    selected = params[key].reject { |value| value.start_with?('_') }.index_with { |value| all[value] }

    selected_first ? selected.merge(facets.except(*selected.keys)) : selected.except(*facets.keys).merge(facets)
  end

  private

  # The facet's values and their counts in the results of every other filter.
  def facet_counts(key, suggest)
    filter = filters[key]
    relation = all(except: filter.try(:except) || key).reorder('')

    filter.facets(relation, suggest:).to_h { |value, count| [value.to_s, count] }
  end
end
