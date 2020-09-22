class IndexStatisticsOnParagraphAndMetric < ActiveRecord::Migration[6.0]
  def change
    add_index :statistics, %i[paragraph metric]
  end
end
