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

      offices = ::Office.pluck(:id, :name).each.with_object({}) { |(id, name), hash| hash[name] = id }

      records.each { |record| record[:office_id] = offices[record[:office]] }

      Statistic.import(records.map { |e| e.slice(:year, :office_id, :filters, :count) }, in_batches: 10_000)
    end
  end
end
