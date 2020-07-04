# == Schema Information
#
# Table name: prosecutors
#
#  id                                :bigint           not null, primary key
#  declarations                      :jsonb
#  name                              :string           not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint           not null
#
# Indexes
#
#  index_prosecutors_on_genpro_gov_sk_prosecutors_list_id  (genpro_gov_sk_prosecutors_list_id)
#  index_prosecutors_on_name                               (name)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_prosecutors_list_id => genpro_gov_sk_prosecutors_lists.id)
#
class Prosecutor < ApplicationRecord
  include Searchable

  belongs_to :genpro_gov_sk_prosecutors_list, class_name: :'GenproGovSk::ProsecutorsList'

  has_many :appointments, dependent: :destroy
  has_many :offices, through: :appointments

  validates :name, presence: true
end
