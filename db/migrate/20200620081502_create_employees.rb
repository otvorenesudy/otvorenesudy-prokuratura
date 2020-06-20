class CreateEmployees < ActiveRecord::Migration[6.0]
  def change
    create_table :employees do |t|
      t.references :office, foreign_key: true, null: false

      t.string :name, null: false
      t.string :position, null: false, limit: 1024
      t.string :phone, null: true
      t.datetime :disabled_at, null: true

      t.timestamps null: false
    end

    add_index :employees, %i[name position]
  end
end
