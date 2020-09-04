class AddMissingIndices < ActiveRecord::Migration[6.0]
  def change
    add_index :offices, :city
    add_index :employees, :name
    add_index :employees, :rank
    add_index :statistics, :year
    add_index :statistics, :metric
    add_index :statistics, :paragraph
  end
end
