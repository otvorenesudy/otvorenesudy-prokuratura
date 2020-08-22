class CreateStatistics < ActiveRecord::Migration[6.0]
  def change
    create_table :statistics do |t|
      t.references :office, null: false, foreign_key: true
      t.integer :year, null: false
      t.string :filters, array: true, null: false
      t.integer :count, null: false
      t.timestamps null: false
    end

    add_index :statistics, :filters
    add_index :statistics, %i[year office_id filters], unique: true
  end
end
