# == Schema Information
#
# Table name: statistics
#
#  id         :bigint           not null, primary key
#  count      :integer          not null
#  metric     :string           not null
#  paragraph  :string
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  office_id  :bigint           not null
#
# Indexes
#
#  index_statistics_on_metric                                       (metric)
#  index_statistics_on_office_id                                    (office_id)
#  index_statistics_on_paragraph                                    (paragraph)
#  index_statistics_on_paragraph_and_metric                         (paragraph,metric)
#  index_statistics_on_year                                         (year)
#  index_statistics_on_year_and_office_id_and_metric_and_paragraph  (year,office_id,metric,paragraph) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#
class Statistic < ApplicationRecord
  belongs_to :office

  validates :year, presence: true, numericality: { in: 2010..2020 }
  validates :metric, presence: true, uniqueness: { scope: %i[year office_id paragraph] }
  validates :count, presence: true, numericality: true

  def self.import_from(records)
    Statistic.delete_all

    offices = ::Office.pluck(:id, :name).each.with_object({}) { |(id, name), hash| hash[name] = id }

    records.each { |record| record[:office_id] = offices[record[:office]] }

    records = records.map { |e| { paragraph: nil }.merge(e.slice(:year, :office_id, :metric, :paragraph, :count)) }.uniq,

    ActiveRecord::Base.logger.silence do
      records.each_with_index do |record, i|
        puts "Statistic # Imported #{i} records" if i % 10_000 == 0 && i > 0

        Statistic.create!({ paragraph: nil }.merge(record.slice(:year, :office_id, :metric, :paragraph, :count)))
      end
    end

    nil
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
      prosecuted_all
      prosecuted_men
      prosecuted_women
      prosecuted_young
      prosecuted_foreigners
      prosecuted_alcohol_abuse
      prosecuted_substance_abuse
    ],
    convicted: %i[convicted_all convicted_men convicted_women convicted_young],
    closure: %i[
      _closure_all
      assignation_of_prosecution
      guilt_and_sentence_agreement
      reconciliation_approval
      suspension_of_prosecution
      suspension_of_prosecution_of_cooperating_accused
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
      prosecution_of_unknown_offender_ended_by_police_by_suspension
      prosecution_of_unknown_offender_ended_by_police_by_other_mean
    ],
    sentence: %i[
      _sentence_all
      sentence_by_os_47_2_tz
      sentence_financial
      sentence_nepo
      sentence_of_compulsary_labor
      sentence_of_forfeiture_of_possesion
      sentence_of_forfeiture_of_property
      sentence_other
      sentence_po
      sentence_prohibition_of_movement
      sentence_prohibition_of_practice
      sentence_prohibition_of_stay
      sentence_under_home_arrest
      sentence_waived
      sentence_of_deportation
    ],
    other: %i[judged_all closed_cases incoming_cases exemption protective_measures_imposed]
  }.freeze
end
