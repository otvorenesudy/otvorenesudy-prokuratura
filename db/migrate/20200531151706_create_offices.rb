class CreateOffices < ActiveRecord::Migration[6.0]
  def change
    create_table :offices do |t|
      t.references :genpro_gov_sk_prosecutors_list, null: false, foreign_key: true

      t.string :name, null: false
      t.string :address, null: false, limit: 1024
      t.string :phone, null: false
      t.string :fax, null: true
      t.string :email, null: false
      t.string :electronic_registry, null: true
      t.jsonb :registry, null: false

      t.timestamps null: false
    end

    add_index :offices, :name, unique: true
  end
end
