class CreateGenproGovSkDeclarations < ActiveRecord::Migration[6.0]
  def change
    create_table :genpro_gov_sk_declarations do |t|
      t.jsonb :data, null: false
      t.binary :file, null: false
      t.string :digest, null: false

      t.timestamps null: false
    end

    add_index :genpro_gov_sk_declarations, :digest, unique: true
  end
end
