class CreateAppointments < ActiveRecord::Migration[6.0]
  def change
    create_table :appointments do |t|
      t.references :office, null: false, foreign_key: true
      t.references :prosecutor, null: false, foreign_key: true
      t.references :genpro_gov_sk_prosecutors_list, null: false, foreign_key: true

      t.datetime :started_at, null: false
      t.datetime :ended_at, null: true
      t.integer :type, null: false

      t.timestamps null: false
    end
  end
end
