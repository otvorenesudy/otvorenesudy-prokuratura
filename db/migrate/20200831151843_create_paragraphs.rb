class CreateParagraphs < ActiveRecord::Migration[6.0]
  def up
    create_table :paragraphs do |t|
      t.integer :type, null: false
      t.string :name, null: false
      t.string :value, null: false

      t.timestamps null: false
    end

    add_index :paragraphs, :value, unique: true

    execute <<-SQL
      CREATE MATERIALIZED VIEW paragraphs_search
      AS
        SELECT
          paragraphs.id,
          lower(unaccent(paragraphs.name)) AS name
        FROM paragraphs;

      CREATE INDEX index_paragraphs_search_on_name ON paragraphs_search USING gin (name gin_trgm_ops);
    SQL
  end

  def down
    remove_index :paragraphs, :value

    execute 'DROP MATERIALIZED VIEW paragraphs_search'
    drop_table :paragraphs
  end
end
