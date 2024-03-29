# == Schema Information
#
# Table name: employees
#
#  id            :bigint           not null, primary key
#  disabled_at   :datetime
#  name          :string           not null
#  name_parts    :jsonb            not null
#  phone         :string
#  position      :string(1024)     not null
#  rank          :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  office_id     :bigint           not null
#  prosecutor_id :bigint
#
# Indexes
#
#  index_employees_on_name                                (name)
#  index_employees_on_name_and_position                   (name,position)
#  index_employees_on_name_parts                          (name_parts)
#  index_employees_on_office_id                           (office_id)
#  index_employees_on_office_id_and_disabled_at_and_rank  (office_id,disabled_at,rank) UNIQUE WHERE (disabled_at IS NULL)
#  index_employees_on_position                            (position)
#  index_employees_on_prosecutor_id                       (prosecutor_id)
#  index_employees_on_rank                                (rank)
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (prosecutor_id => prosecutors.id)
#
class Employee < ApplicationRecord
  ATTORNEY_GENERAL_POSITION = [
    'generálny prokurátor Slovenskej republiky',
    'krajská prokurátorka',
    'krajský prokurátor',
    'okresná prokurátorka',
    'okresný prokurátor',
    'špeciálny prokurátor'
  ]

  belongs_to :office
  belongs_to :prosecutor, optional: true

  validates :name, presence: true
  validates :position, presence: true
  validates :rank, presence: true, numericality: { greater_than: 0, only_integer: true }

  scope :active, -> { where(disabled_at: nil) }
  scope :as_prosecutor, -> { where.not(prosecutor_id: nil) }

  def self.attorney_general
    where(position: ATTORNEY_GENERAL_POSITION)
  end
end
