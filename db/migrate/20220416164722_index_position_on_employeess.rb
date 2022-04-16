class IndexPositionOnEmployeess < ActiveRecord::Migration[6.0]
  def change
    add_index :employees, :position
  end
end
