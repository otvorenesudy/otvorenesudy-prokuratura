class Search
  class DecreesCountFilter
    def initialize(buckets)
      @buckets = buckets
    end

    def filter(relation, params)
      return relation if params[:decrees_count].blank?

      ranges =
        params[:decrees_count].map do |value|
          _, min, max = *value.match(/\A(\d+)\.\.(\d+)\z/)

          min.to_i..max.to_i
        end

      relation.where(decrees_count: ranges)
    end

    def facets(relation, suggest:)
      facets = relation.group(:decrees_count).count

      @buckets.map { |range, value| [range.to_s, facets.values_at(*range.to_a).compact.sum] }.to_h
    end
  end
end
