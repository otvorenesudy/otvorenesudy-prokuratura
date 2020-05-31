class Prosecutor < ApplicationRecord
  belongs_to :genpro_gov_sk_prosecutors_list, class_name: :'GenproGovSk::ProsecutorsList'

  has_many :appointments
  has_many :offices, through: :appointments

  validates :name, presence: true, uniqueness: true
end
