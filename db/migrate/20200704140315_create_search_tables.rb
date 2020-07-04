class CreateSearchTables < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE MATERIALIZED VIEW offices_search
      AS
        SELECT
          offices.id,
          lower(unaccent(offices.name)) AS name,
          lower(unaccent(offices.address)) AS address,
          lower(unaccent(offices.city)) AS city,
          lower(unaccent(array_to_string(array_agg(employees.name), ', '))) AS employees
        FROM offices
        JOIN employees ON employees.office_id = offices.id
        GROUP BY offices.id;

      CREATE INDEX index_offices_search_on_name ON offices_search USING gin (name gin_trgm_ops);
      CREATE INDEX index_offices_search_on_address ON offices_search USING gin (address gin_trgm_ops);
      CREATE INDEX index_offices_search_on_city ON offices_search USING gin (city gin_trgm_ops);
      CREATE INDEX index_offices_search_on_employees ON offices_search USING gin (employees gin_trgm_ops);
    SQL
  end

  def down
    execute 'DROP MATERIALIZED VIEW offices_search'
  end
end
