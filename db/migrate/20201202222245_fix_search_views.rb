class FixSearchViews < ActiveRecord::Migration[6.0]
  def up
    execute 'DROP MATERIALIZED VIEW offices_search'
    execute 'DROP MATERIALIZED VIEW prosecutors_search'

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
        LEFT OUTER JOIN employees ON employees.office_id = offices.id
        LEFT OUTER JOIN appointments ON
          appointments.office_id = offices.id AND
          appointments.ended_at IS NULL
        LEFT OUTER JOIN prosecutors ON appointments.prosecutor_id = prosecutors.id;

      CREATE INDEX index_offices_search_on_name ON offices_search USING gin (name gin_trgm_ops);
      CREATE INDEX index_offices_search_on_address ON offices_search USING gin (address gin_trgm_ops);
      CREATE INDEX index_offices_search_on_city ON offices_search USING gin (city gin_trgm_ops);
      CREATE INDEX index_offices_search_on_employee ON offices_search USING gin (employee gin_trgm_ops);
    SQL

    execute <<-SQL
      CREATE MATERIALIZED VIEW prosecutors_search
      AS
        SELECT
          prosecutors.id,
          lower(unaccent(prosecutors.name)) AS name,
          lower(unaccent(offices.name)) AS office,
          lower(unaccent(prosecutors.declarations :: text)) AS declarations,
          lower(unaccent(offices.city :: text)) AS city
        FROM prosecutors
        LEFT OUTER JOIN appointments ON
          appointments.prosecutor_id = prosecutors.id AND
          appointments.ended_at IS NULL
        LEFT OUTER JOIN offices ON appointments.office_id = offices.id;

      CREATE INDEX index_prosecutors_search_on_name ON prosecutors_search USING gin (name gin_trgm_ops);
      CREATE INDEX index_prosecutors_search_on_office ON prosecutors_search USING gin (office gin_trgm_ops);
      CREATE INDEX index_prosecutors_search_on_declarations ON prosecutors_search USING gin (declarations gin_trgm_ops);
      CREATE INDEX index_prosecutors_search_on_city ON prosecutors_search USING gin (city gin_trgm_ops);
    SQL
  end

  def down
    execute 'DROP MATERIALIZED VIEW offices_search'
    execute 'DROP MATERIALIZED VIEW prosecutors_search'

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
        JOIN employees ON employees.office_id = offices.id
        JOIN appointments ON
          appointments.office_id = offices.id AND
          appointments.ended_at IS NULL
        JOIN prosecutors ON appointments.prosecutor_id = prosecutors.id;

      CREATE INDEX index_offices_search_on_name ON offices_search USING gin (name gin_trgm_ops);
      CREATE INDEX index_offices_search_on_address ON offices_search USING gin (address gin_trgm_ops);
      CREATE INDEX index_offices_search_on_city ON offices_search USING gin (city gin_trgm_ops);
      CREATE INDEX index_offices_search_on_employee ON offices_search USING gin (employee gin_trgm_ops);
    SQL

    execute <<-SQL
      CREATE MATERIALIZED VIEW prosecutors_search
      AS
        SELECT
          prosecutors.id,
          lower(unaccent(prosecutors.name)) AS name,
          lower(unaccent(offices.name)) AS office,
          lower(unaccent(prosecutors.declarations :: text)) AS declarations,
          lower(unaccent(offices.city :: text)) AS city
        FROM prosecutors
        JOIN appointments ON
          appointments.prosecutor_id = prosecutors.id AND
          appointments.ended_at IS NULL
        JOIN offices ON appointments.office_id = offices.id;

      CREATE INDEX index_prosecutors_search_on_name ON prosecutors_search USING gin (name gin_trgm_ops);
      CREATE INDEX index_prosecutors_search_on_office ON prosecutors_search USING gin (office gin_trgm_ops);
      CREATE INDEX index_prosecutors_search_on_declarations ON prosecutors_search USING gin (declarations gin_trgm_ops);
      CREATE INDEX index_prosecutors_search_on_city ON prosecutors_search USING gin (city gin_trgm_ops);
    SQL
  end
end
