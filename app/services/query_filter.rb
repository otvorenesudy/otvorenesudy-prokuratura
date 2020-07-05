class QueryFilter
  def self.filter(relation, params, columns:, order: nil)
    return relation unless params[:q]

    model = relation.model
    query = ActiveRecord::Base.connection.quote(params[:q])
    columns = columns.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }

    search =
      model.from("#{relation.table_name}_search").where(
        columns.map do |column|
          "
            #{column} LIKE lower(unaccent(:like)) OR
            similarity(#{column}, lower(unaccent(:similarity))) > 0.3
          "
        end.join(' OR '),
        like: "%#{params[:q]}%", similarity: params[:q]
      )

    if order
      search =
        search.reorder(
          Arel.sql(
            columns.map { |column| "similarity(#{column}, lower(unaccent(#{query})))" }.join(' + ') +
              " #{order || 'DESC'}"
          )
        )
    end

    ids = search.pluck("#{relation.table_name}_search.id")
    result = relation.where(id: ids)

    return result unless order

    result.reorder(Arel.sql("array_position(ARRAY[#{ids.join(', ')}] :: text[], #{relation.table_name}.id :: text)"))
  end
end
