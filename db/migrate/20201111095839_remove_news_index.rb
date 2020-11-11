class RemoveNewsIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :prosecutors, :news
    remove_index :offices, :news
  end
end
