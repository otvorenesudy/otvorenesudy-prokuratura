# == Schema Information
#
# Table name: employees
#
#  id          :bigint           not null, primary key
#  disabled_at :datetime
#  name        :string           not null
#  phone       :string
#  position    :string(1024)     not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  office_id   :bigint           not null
#
# Indexes
#
#  index_employees_on_name_and_position  (name,position)
#  index_employees_on_office_id          (office_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#
class Employee < ApplicationRecord
  belongs_to :office

  validates :name, presence: true
  validates :position, presence: true

  scope :active, -> { where(disabled_at: nil) }
end
