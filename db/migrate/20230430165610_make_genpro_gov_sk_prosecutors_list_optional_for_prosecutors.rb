class MakeGenproGovSkProsecutorsListOptionalForProsecutors < ActiveRecord::Migration[6.0]
  def change
    change_column :prosecutors, :genpro_gov_sk_prosecutors_list_id, :integer, null: true
  end
end
