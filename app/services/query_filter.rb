# frozen_string_literal: true

class QueryFilter
  def self.filter(relation, params, columns:)
    return relation if params[:q].blank?

    model = relation.model
    query = ActiveRecord::Base.connection.quote(params[:q])
    columns = columns.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }
    matches = columns.map do |column|
      "#{column} LIKE lower(unaccent(:like)) OR similarity(#{column}, lower(unaccent(:similarity))) > 0.5"
    end
    similarity = columns.map { |column| "similarity(#{column}, lower(unaccent(#{query})))" }.join(' + ')

    search =
      model
      .from("#{relation.table_name}_search")
      .where(matches.join(' OR '), like: "%#{params[:q]}%", similarity: params[:q])
      .reorder(Arel.sql("#{similarity} DESC"))

    ids = search.pluck("#{relation.table_name}_search.id")

    relation.where(id: ids)
  end
end
