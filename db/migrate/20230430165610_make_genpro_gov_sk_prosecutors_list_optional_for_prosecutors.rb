class MakeGenproGovSkProsecutorsListOptionalForProsecutors < ActiveRecord::Migration[6.0]
  def up
    change_column :prosecutors, :genpro_gov_sk_prosecutors_list_id, :bigint, null: true
  end

  def down
    change_column :prosecutors, :genpro_gov_sk_prosecutors_list_id, :bigint, null: false
  end
end
