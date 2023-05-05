class MakeGenproGovSkProsecutorsListOptionalForAppointments < ActiveRecord::Migration[6.0]
  def up
    change_column :appointments, :genpro_gov_sk_prosecutors_list_id, :integer, null: true
  end

  def down
    change_column :appointments, :genpro_gov_sk_prosecutors_list_id, :integer, null: false
  end
end
