class CreateDecrees < ActiveRecord::Migration[6.0]
  def change
    create_table :genpro_gov_sk_decrees do |t|
      t.jsonb :data, null: false
      t.binary :file, null: false
      t.string :digest, null: false

      t.timestamps null: false
    end

    add_index :genpro_gov_sk_decrees, :digest, unique: true

    create_table :decrees do |t|
      t.references :genpro_gov_sk_decree, null: false, foreign_key: true
      t.references :office, null: true, foreign_key: true
      t.references :prosecutor, null: true, foreign_key: true

      t.string :url, null: false
      t.string :number, null: false
      t.string :file_info, null: false
      t.integer :file_type, null: false
      t.date :effective_on, null: false
      t.date :published_on, null: false
      t.string :file_number, null: false
      t.string :resolution, null: false
      t.string :means_of_resolution, null: false
      t.text :text, null: false
      
      t.timestamps null: false
    end

    add_index :decrees, :url
    add_index :decrees, :effective_on
    add_index :decrees, :published_on
  end
end
