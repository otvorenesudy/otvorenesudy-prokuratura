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

      Statistic.import(records.map { |e| e.slice(:year, :office_id, :filters, :count) })
    end
  end
end
