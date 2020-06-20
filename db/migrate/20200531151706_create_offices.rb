class CreateOffices < ActiveRecord::Migration[6.0]
  def change
    create_table :genpro_gov_sk_offices do |t|
      t.jsonb :data, null: false
      t.binary :file, null: false
      t.string :digest, null: false

      t.timestamps null: false
    end

    add_index :genpro_gov_sk_offices, :digest, unique: true

    create_table :offices do |t|
      t.references :genpro_gov_sk_office, null: false, foreign_key: true

      t.string :name, null: false
      t.string :address, null: false, limit: 1024
      t.string :phone, null: false
      t.string :fax, null: true
      t.string :email, null: true
      t.string :electronic_registry, null: true
      t.jsonb :registry, null: false

      t.timestamps null: false
    end

    add_index :offices, :name, unique: true
  end
end
