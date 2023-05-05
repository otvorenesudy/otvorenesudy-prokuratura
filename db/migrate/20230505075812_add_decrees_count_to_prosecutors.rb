class AddDecreesCountToProsecutors < ActiveRecord::Migration[6.0]
  def change
    add_column :prosecutors, :decrees_count, :bigint, default: 0
  end
end
