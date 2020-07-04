class Search
  attr_reader :repository, :filters, :params

  def initialize(repository, params:, filters:)
    @repository = repository
    @params = params.to_h.freeze
    @filters = filters.freeze
  end

  def all(except: [])
    except = [*except]

    filters.reject { |(key, _)| key.in?(except) }.inject(repository) do |relation, (key, filter)|
      filter.filter(relation, params)
    end
  end

  def paginated
    @paginated ||= all.page(params[:page] || 1).per(15)
  end

  def facets_for(key)
    filters[key].facets(all(except: key))
  end
end
