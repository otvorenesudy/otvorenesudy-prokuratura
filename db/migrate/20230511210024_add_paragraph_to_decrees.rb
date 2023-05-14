class AddParagraphToDecrees < ActiveRecord::Migration[6.0]
  def change
    add_column :decrees, :paragraph_id, :bigint
    add_column :decrees, :paragraph_section, :string
  end
end
