class MakeDecreeMeansOfResolutionOptional < ActiveRecord::Migration[6.0]
  def change
    change_column :decrees, :means_of_resolution, :string, null: true
  end
end
