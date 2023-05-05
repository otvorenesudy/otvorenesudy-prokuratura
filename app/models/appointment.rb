# == Schema Information
#
# Table name: appointments
#
#  id                                :bigint           not null, primary key
#  ended_at                          :datetime
#  place                             :string
#  started_at                        :datetime         not null
#  type                              :integer          not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :integer
#  office_id                         :bigint
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

  belongs_to :genpro_gov_sk_prosecutors_list, class_name: :'GenproGovSk::ProsecutorsList', optional: true
  belongs_to :prosecutor
  belongs_to :office, required: false

  validates :started_at, presence: true
  validates :type, presence: true
  validates :place, presence: true, unless: :office_id?
  validates :office, presence: true, unless: :place?

  enum type: %i[fixed temporary]

  scope :current, -> { where(ended_at: nil) }
  scope :past, -> { where.not(ended_at: nil) }
  scope :probable, -> { where(genpro_gov_sk_prosecutors_list: nil) }

  def current?
    ended_at.blank?
  end
end
