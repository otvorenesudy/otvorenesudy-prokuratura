class Appointment < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :genpro_gov_sk_prosecutors_list, class_name: :'GenproGovSk::ProsecutorsList'
  belongs_to :prosecutor
  belongs_to :office

  validates :started_at, presence: true
  validates :type, presence: true

  enum type: %i[fixed temporary]

  scope :current, -> { where(ended_at: nil) }
end
