class MakeIntegerIdsBigInt < ActiveRecord::Migration[6.0]
  def change
    change_column :prosecutors, :genpro_gov_sk_prosecutors_list_id, :bigint
    change_column :appointments, :genpro_gov_sk_prosecutors_list_id, :bigint
  end
end
