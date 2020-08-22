class Statistic < ApplicationRecord
  belongs_to :office

  validates :year, presence: true, numericality: { in: 2010..2020 }
  validates :filters, presence: true
  validates :count, presence: true, numericality: true

  def self.import_from(statistics)
    Statistic.transaction do
      Statistic.lock
      Statistic.delete_all

      statistics.each do |attributes|
        next if attributes[:statistics].blank?

        year = attributes[:year]
        office = ::Office.find_by(name: attributes[:office])

        attributes[:statistics].each do |statistic|
          next if statistic[:count].blank?

          begin
            create!(statistic.slice(:filters, :count).merge(office: office, year: year))
          rescue StandardError
            binding.pry
          end
        end
      end
    end
  end
end
