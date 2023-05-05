class AddDecreesCountToOffices < ActiveRecord::Migration[6.0]
  def change
    add_column :offices, :decrees_count, :bigint, default: 0
  end
end
