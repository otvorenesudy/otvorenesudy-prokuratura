# == Schema Information
#
# Table name: crimes
#
#  id         :bigint           not null, primary key
#  count      :integer          not null
#  metric     :string           not null
#  paragraph  :string
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_crimes_on_year_and_metric_and_paragraph  (year,metric,paragraph) UNIQUE
#
class Crime < ApplicationRecord
  validates :year, presence: true, numericality: { in: 1997..2020 }
  validates :metric,
            presence: true,
            uniqueness: {
              scope: %i[year paragraph]
            },
            inclusion: {
              in: -> { GROUPS.values.flatten }
            }
  validates :count, presence: true, numericality: true

  def self.import_from(records)
    Crime.transaction do
      Crime.delete_all
      Crime.lock

      Rails.logger.silence do
        records.each do |record|
          Crime.upsert(
            record.slice(:year, :metric, :paragraph, :count),
            unique_by: %i[year metric paragraph],
            returning: false
          )
        end
      end
    end

    nil
  end

  GROUPS = {
    crimes: %i[
      crime_discovered
      crime_solved
      crime_denominated_damage
      crime_additionally_solved
      crime_alcohol_abuse
      crime_drug_abuse
      crime_underage_offender
      crime_underage_offender_alcohol_abuse
      crime_underage_offender_drug_abuse
      crime_adolescent_offender
      crime_adolescent_offender_alcohol_abuse
      crime_adolescent_offender_drug_abuse
    ],
    persons: %i[
      persons_all
      persons_alcohol_abuse
      persons_drug_abuse
      persons_underage_offender
      persons_underage_offender_alcohol_abuse
      persons_underage_offender_drug_abuse
      persons_adolescent_offender
      persons_adolescent_offender_alcohol_abuse
      persons_adolescent_offender_drug_abuse
    ]
  }
end
