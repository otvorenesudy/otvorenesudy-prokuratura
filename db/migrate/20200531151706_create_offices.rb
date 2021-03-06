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
      t.references :genpro_gov_sk_office, null: true, foreign_key: true

      t.string :name, null: false
      t.integer :type, null: true
      t.string :address, null: false, limit: 1024
      t.string :additional_address, null: true, limit: 1024
      t.string :zipcode, null: false
      t.string :city, null: false
      t.string :phone, null: false
      t.string :fax, null: true
      t.string :email, null: true
      t.string :electronic_registry, null: true
      t.jsonb :registry, null: false
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.datetime :destroyed_at, null: true

      t.timestamps null: false
    end

    add_index :offices, :name, unique: true
    add_index :offices, :type
    add_index :offices,
              :type,
              name: :index_offices_on_unique_general_type, unique: true, where: "type = #{Office.types[:general]}"
    add_index :offices,
              :type,
              name: :index_offices_on_unique_specialized_type,
              unique: true,
              where: "type = #{Office.types[:specialized]}"

    add_index :offices, :destroyed_at
  end
end
