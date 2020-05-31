class CreateOffices < ActiveRecord::Migration[6.0]
  def change
    create_table :offices do |t|
      t.references :genpro_gov_sk_prosecutors_list, null: false, foreign_key: true

      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :offices, :name, unique: true
  end
end
