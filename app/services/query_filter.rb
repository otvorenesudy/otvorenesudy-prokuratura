class QueryFilter
  def self.filter(relation, params, columns:)
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
      ).reorder(
        Arel.sql(columns.map { |column| "similarity(#{column}, lower(unaccent(#{query})))" }.join(' + ') + ' DESC')
      )

    relation.where(id: search.select("#{relation.table_name}_search.id")).reorder(
      Arel.sql("array_position(ARRAY(#{search.select("#{relation.table_name}_search.id :: text").to_sql}), id :: text)")
    )
  end
end
