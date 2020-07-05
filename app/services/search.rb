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

  def facets_for(key, suggest: nil)
    key = key.to_sym

    filters[key].facets(all(except: key).reorder(''), suggest: suggest).tap do |facets|
      if params[key].present? && suggest.nil?
        values = (params[key] - facets.keys).each.with_object({}) { |value, hash| hash[value] = nil }

        facets.merge!(values)
      end
    end
  end
end
