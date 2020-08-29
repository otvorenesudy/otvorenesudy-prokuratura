# == Schema Information
#
# Table name: statistics
#
#  id         :bigint           not null, primary key
#  count      :integer          not null
#  filters    :string           not null, is an Array
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  office_id  :bigint           not null
#
# Indexes
#
#  index_statistics_on_filters                         (filters)
#  index_statistics_on_office_id                       (office_id)
#  index_statistics_on_year_and_office_id_and_filters  (year,office_id,filters) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#
class Statistic < ApplicationRecord
  belongs_to :office

  validates :year, presence: true, numericality: { in: 2010..2020 }
  validates :filters, presence: true, uniqueness: { scope: %i[year office_id] }
  validates :count, presence: true, numericality: true

  def self.import_from(records)
    Statistic.transaction do
      Statistic.delete_all
      Statistic.lock

      offices = ::Office.pluck(:id, :name).each.with_object({}) { |(id, name), hash| hash[name] = id }

      records.each { |record| record[:office_id] = offices[record[:office]] }

      Statistic.import(
        records.map { |e| e.slice(:year, :office_id, :filters, :count) }.uniq,
        in_batches: 10_000, validate: false
      )
    end

    Statistic.refresh_search_view
  end

  GROUPS = {
    accused: %i[
      accused_all
      accused_men
      accused_women
      accused_age_14_to_15_all
      accused_age_14_to_15_boys
      accused_age_14_to_15_girls
      accused_age_16_to_18_all
      accused_age_16_to_18_boys
      accused_age_16_to_18_girls
      accused_age_19_to_21_all
      accused_age_22_to_30_all
      accused_age_31_to_40_all
      accused_age_41_to_50_all
      accused_age_51_to_60_all
      accused_age_61_and_more_all
      accused_recidivists_all
      accused_recidivists_dangerous
      accused_recidivists_only
      accused_alcohol_abuse
      accused_substance_abuse
      accused_by_paragraph_204
      accused_people_for_intentional_crimes
      accused_people_for_intentional_crimes_of_same_nature
    ],
    prosecuted: %i[
      prosecuted_alcohol_abuse
      prosecuted_all
      prosecuted_foreigners
      prosecuted_men
      prosecuted_substance_abuse
      prosecuted_women
      prosecuted_young
    ],
    convicted: %i[convicted_all convicted_men convicted_women convicted_young],
    closure: %i[
      assignation_of_prosuction
      cessation_of_prosecution
      conditional_cessation_by_court
      conditional_cessation_by_prosecutor
      conditional_cessation_by_prosecutor_all
      conditional_cessation_of_accused_all
      conditional_cessation_of_accused_and_proven
      conditional_cessation_of_accused_and_proven_by_prosecutor
      conditional_cessation_of_accused_by_prosecutor
      conditional_cessation_of_cooperating_accused_and_proven
      conditional_cessation_of_cooperating_accused_by_prosecutor
      guilt_and_sentence_agreement
      reconciliation_approval
      suspension_of_prosecution
      suspension_of_prosecution_of_cooperating_accused
      valid_court_decision_all
      valid_court_decision_on_assignation_of_prosecution
      valid_court_decision_on_cessation_of_prosecution
      valid_court_decision_on_conditional_cessation_of_prosecution
      valid_court_decision_on_conditional_cessation_of_prosecution_of_cooperating_accused
      valid_court_decision_on_conviction_of_people
      valid_court_decision_on_exemption
      valid_court_decision_on_reconciliation_approval
      valid_court_decision_on_suspension_of_prosecution
      valid_court_decision_on_waiver_of_sentence
      valid_court_decision_only_convicted_with_guilt_and_sentence_agreement
      valid_other_court_decision
    ],
    prosecution_by_police: %i[
      prosecution_of_unknown_offender_ended_by_police
      prosecution_of_unknown_offender_ended_by_police_by_assignation
      prosecution_of_unknown_offender_ended_by_police_by_cessation
      prosecution_of_unknown_offender_ended_by_police_by_other_mean
      prosecution_of_unknown_offender_ended_by_police_by_suspension
    ]
  }.freeze
end
