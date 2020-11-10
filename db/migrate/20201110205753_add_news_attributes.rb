class AddNewsAttributes < ActiveRecord::Migration[6.0]
  def change
    add_column :prosecutors, :news, :jsonb
    add_column :offices, :news, :jsonb

    add_index :prosecutors, :news
    add_index :offices, :news
  end
end
