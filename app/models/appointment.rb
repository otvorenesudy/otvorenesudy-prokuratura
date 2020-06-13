# == Schema Information
#
# Table name: appointments
#
#  id                                :bigint           not null, primary key
#  ended_at                          :datetime
#  started_at                        :datetime         not null
#  type                              :integer          not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint           not null
#  office_id                         :bigint           not null
#  prosecutor_id                     :bigint           not null
#
# Indexes
#
#  index_appointments_on_genpro_gov_sk_prosecutors_list_id  (genpro_gov_sk_prosecutors_list_id)
#  index_appointments_on_office_id                          (office_id)
#  index_appointments_on_prosecutor_id                      (prosecutor_id)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_prosecutors_list_id => genpro_gov_sk_prosecutors_lists.id)
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (prosecutor_id => prosecutors.id)
#
class Appointment < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :genpro_gov_sk_prosecutors_list, class_name: :'GenproGovSk::ProsecutorsList'
  belongs_to :prosecutor
  belongs_to :office

  validates :started_at, presence: true
  validates :type, presence: true

  enum type: %i[fixed temporary]

  scope :current, -> { where(ended_at: nil) }

  def current?
    ended_at.blank?
  end
end
