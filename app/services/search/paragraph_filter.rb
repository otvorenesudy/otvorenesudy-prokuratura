class Search
  class ParagraphFilter
    def initialize(model)
      @model = model
    end

    def filter(relation, params)
      return relation if params[:paragraph].blank?

      relation.joins(decrees: :paragraph).where(paragraphs: { value: params[:paragraph] }).distinct
    end

    def facets_limit
      nil
    end

    def facets(relation, suggest:)
      paragraphs = ::QueryFilter.filter(Paragraph.all, { q: suggest }, columns: %i[name])

      relation
        .joins(decrees: :paragraph)
        .merge(paragraphs)
        .reorder(
          Arel.sql("COUNT(DISTINCT #{ActiveRecord::Base.connection.quote_column_name(@model.table_name)}.id) DESC")
        )
        .group('paragraphs.value')
        .distinct
        .count
    end
  end
end
