class CreateEmployees < ActiveRecord::Migration[6.0]
  def change
    create_table :employees do |t|
      t.references :office, foreign_key: true, null: false
      t.references :prosecutor, foreign_key: true, null: true

      t.string :name, null: false
      t.string :identifiable_name, null: false
      t.string :position, null: false, limit: 1024
      t.integer :rank, null: false
      t.string :phone, null: true
      t.datetime :disabled_at, null: true

      t.timestamps null: false
    end

    add_index :employees, %i[name position]
    add_index :employees, %i[office_id disabled_at rank], unique: true, where: 'disabled_at IS NULL'
  end
end
