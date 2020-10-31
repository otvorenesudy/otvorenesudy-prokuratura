class Search
  attr_reader :repository, :filters, :params

  def initialize(repository, params:, filters:)
    @repository = repository
    @params = params.to_h.with_indifferent_access
    @filters = filters.freeze
  end

  def all(except: [])
    except = [*except].map(&:to_sym)

    filters.reject { |(key, _)| key.to_sym.in?(except) }.inject(repository) do |relation, (key, filter)|
      next filter.filter(relation, params) if filter.respond_to?(:filter)

      relation
    end
  end

  def paginated
    all.page(params[:page] || 1).per(15)
  end

  def facets_for(key, suggest: nil, limit: nil)
    key = key.to_sym
    except = filters[key].try(:except) || key
    limit = limit || (filters[key].respond_to?(:facets_limit) ? filters[key].facets_limit : 10)

    all = filters[key].facets(all(except: except).reorder(''), suggest: suggest || params["#{key}_suggest"])
    facets = limit ? all.first(limit).to_h : all

    return facets if params[key].blank? || suggest.present?

    values =
      (params[key].select { |e| !e.match(/\A_/) } - facets.keys.map(&:to_s)).each.with_object({}) do |value, hash|
        hash[value] = all[value] || nil
      end

    values.merge(facets)
  end
end
