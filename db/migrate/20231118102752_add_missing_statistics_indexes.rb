class AddMissingStatisticsIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :statistics, :paragraph, where: 'paragraph IS NOT NULL', name: :index_statistics_on_present_paragraph
  end
end
