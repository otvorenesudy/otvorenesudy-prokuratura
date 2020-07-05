class CreateProsecutors < ActiveRecord::Migration[6.0]
  def change
    create_table :prosecutors do |t|
      t.references :genpro_gov_sk_prosecutors_list, null: false, foreign_key: true

      t.string :name, null: false
      t.string :identifiable_name, null: false
      t.jsonb :declarations, null: true

      t.timestamps null: false
    end

    add_index :prosecutors, :name
  end
end
