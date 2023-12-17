class CreateCrimes < ActiveRecord::Migration[6.0]
  def change
    create_table :crimes do |t|
      t.integer :year, null: false
      t.string :metric, null: false
      t.string :paragraph, null: true
      t.integer :count, null: false
      t.timestamps null: false
    end

    add_index :crimes, %i[year metric paragraph], unique: true
  end
end
