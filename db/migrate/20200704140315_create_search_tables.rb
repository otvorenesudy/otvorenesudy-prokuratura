class CreateSearchTables < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE MATERIALIZED VIEW offices_search
      AS
        SELECT
          offices.id AS id,
          lower(unaccent(offices.name)) AS name,
          lower(unaccent(offices.address)) AS address,
          lower(unaccent(offices.city)) AS city,
          lower(unaccent(employees.name)) AS employee
        FROM offices
        JOIN employees ON employees.office_id = offices.id;

      CREATE INDEX index_offices_search_on_name ON offices_search USING gin (name gin_trgm_ops);
      CREATE INDEX index_offices_search_on_address ON offices_search USING gin (address gin_trgm_ops);
      CREATE INDEX index_offices_search_on_city ON offices_search USING gin (city gin_trgm_ops);
      CREATE INDEX index_offices_search_on_employee ON offices_search USING gin (employee gin_trgm_ops);
    SQL

    execute <<-SQL
      CREATE MATERIALIZED VIEW prosecutors_search
      AS
        SELECT
          prosecutors.id
        FROM prosecutors;
    SQL
  end

  def down
    execute 'DROP MATERIALIZED VIEW offices_search'
    execute 'DROP MATERIALIZED VIEW prosecutors_search'
  end
end
