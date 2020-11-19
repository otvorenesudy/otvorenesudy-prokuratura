module Offices
  module Indicators
    extend ActiveSupport::Concern

    def convicted_people_by_year
      @convicted_people_by_year ||=
        statistics.where(metric: :convicted_all).where.not(paragraph: nil).group(:year).order(year: :asc).sum(:count)
    end

    def average_convicted_people_yearly
      @average_convicted_people_yearly ||=
        begin
          if convicted_people_by_year.blank?
            nil
          else
            convicted_people_by_year.values.sum / convicted_people_by_year.keys.size.to_f
          end
        end
    end

    def average_incoming_cases_per_prosecutor_monthly_by_years
      @average_incoming_cases_per_prosecutor_monthly_by_years ||=
        self.class.indicators[id].try { |e| e[:average_incoming_cases_per_prosecutor_monthly_by_years] }
    end

    def average_incoming_cases_per_prosecutor_monthly
      @average_incoming_cases_per_prosecutor_monthly ||=
        begin
          if average_incoming_cases_per_prosecutor_monthly_by_years.blank?
            nil
          else
            average_incoming_cases_per_prosecutor_monthly_by_years.values.sum /
              average_incoming_cases_per_prosecutor_monthly_by_years.keys.size.to_f
          end
        end
    end

    def average_incoming_cases_per_prosecutor_yearly_by_years
      @average_incoming_cases_per_prosecutor_yearly_by_years ||=
        self.class.indicators[id].try { |e| e[:average_incoming_cases_per_prosecutor_yearly_by_years] }
    end

    def average_incoming_cases_per_prosecutor_yearly
      @average_incoming_cases_per_prosecutor_yearly ||=
        begin
          if average_incoming_cases_per_prosecutor_yearly_by_years.blank?
            nil
          else
            average_incoming_cases_per_prosecutor_yearly_by_years.values.sum /
              average_incoming_cases_per_prosecutor_yearly_by_years.keys.size.to_f
          end
        end
    end

    class_methods do
      def indicators
        @indicators ||= prepare_indicators
      end

      private

      def prepare_indicators
        lines = CSV.readlines(Rails.root.join('data', 'offices-incoming-cases.csv'))

        lines[2..-1].each.with_object({}) do |row, hash|
          name = row[0..1].join(' ').gsub(/OP/, 'Okresná prokuratúra').gsub(/KP/, 'Krajská prokuratúra').strip

          office = ::Office.find_by!(name: name)

          hash[office.id] = {
            average_incoming_cases_per_prosecutor_monthly_by_years:
              row[2..11].reverse.each.with_index.with_object({}) { |(value, i), values| values[2010 + i] = value.to_f },
            average_incoming_cases_per_prosecutor_yearly_by_years:
              row[13..23].reverse.each.with_index.with_object({}) { |(value, i), values| values[2010 + i] = value.to_f }
          }
        end
      end
    end
  end
end
