class IndexParagraphsOnType < ActiveRecord::Migration[6.0]
  def change
    add_index :paragraphs, :type
  end
end
