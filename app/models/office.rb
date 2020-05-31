class Office < ApplicationRecord
  belongs_to :genpro_gov_sk_prosecutors_list, class_name: :'GenproGovSk::ProsecutorsList'

  validates :name, presence: true, uniqueness: true
end
