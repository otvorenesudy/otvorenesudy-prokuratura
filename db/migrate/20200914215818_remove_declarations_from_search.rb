class RemoveDeclarationsFromSearch < ActiveRecord::Migration[6.0]
  def up
    execute 'DROP MATERIALIZED VIEW prosecutors_search'
    execute <<-SQL
      CREATE MATERIALIZED VIEW prosecutors_search
      AS
        SELECT
          prosecutors.id,
          lower(unaccent(prosecutors.name)) AS name,
          lower(unaccent(offices.name)) AS office,
          lower(unaccent(offices.city :: text)) AS city
        FROM prosecutors
        JOIN appointments ON
          appointments.prosecutor_id = prosecutors.id AND
          appointments.ended_at IS NULL
        JOIN offices ON appointments.office_id = offices.id;

      CREATE INDEX index_prosecutors_search_on_name ON prosecutors_search USING gin (name gin_trgm_ops);
      CREATE INDEX index_prosecutors_search_on_office ON prosecutors_search USING gin (office gin_trgm_ops);
      CREATE INDEX index_prosecutors_search_on_city ON prosecutors_search USING gin (city gin_trgm_ops);
    SQL
  end

  def down
    execute 'DROP MATERIALIZED VIEW prosecutors_search'
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
