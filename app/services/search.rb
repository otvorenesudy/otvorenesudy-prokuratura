class Search
  attr_reader :repository, :filters, :params

  def initialize(repository, params:, filters:)
    @repository = repository
    @params = params.to_h.with_indifferent_access
    @filters = filters.freeze
  end

  def all(except: [])
    except = [*except]

    filters.reject { |(key, _)| key.in?(except) }.inject(repository) do |relation, (key, filter)|
      filter.filter(relation, params)
    end
  end

  def paginated
    all.page(params[:page] || 1).per(15)
  end

  def facets_for(key, suggest: nil, limit: 10)
    key = key.to_sym

    all = filters[key].facets(all(except: key).reorder(''), suggest: suggest)
    facets = all.first(limit).to_h

    return facets if params[key].blank? || suggest.present?

    values =
      (params[key] - facets.keys.map(&:to_s)).each.with_object({}) { |value, hash| hash[value] = all[value] || nil }

    values.merge(facets)
  end
end
