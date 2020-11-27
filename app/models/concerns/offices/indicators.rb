module Offices
  module Indicators
    extend ActiveSupport::Concern

    def convicted_people_by_years
      @convicted_people_by_years ||=
        statistics.where(metric: :convicted_all).where.not(paragraph: nil).group(:year).order(year: :asc).sum(:count)
    end

    def average_convicted_people_yearly
      @average_convicted_people_yearly ||=
        begin
          if convicted_people_by_years.blank?
            nil
          else
            convicted_people_by_years.values.sum / convicted_people_by_years.keys.size.to_f
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
        if average_incoming_cases_per_prosecutor_yearly_by_years.blank?
          nil
        else
          average_incoming_cases_per_prosecutor_yearly_by_years.values.sum /
            average_incoming_cases_per_prosecutor_yearly_by_years.keys.size.to_f
        end
    end

    def average_filed_prosecutions_per_prosecutor_monthly_by_years
      @average_filed_prosecutoions_per_prosecutor_monthly_by_years ||=
        self.class.indicators[id].try { |e| e[:average_filed_prosecutions_per_prosecutor_monthly_by_years] }
    end

    def average_filed_prosecutions_per_prosecutor_monthly
      @average_filed_prosecutions_per_prosecutor_monthly ||=
        if average_filed_prosecutions_per_prosecutor_monthly_by_years.blank?
          nil
        else
          average_filed_prosecutions_per_prosecutor_monthly_by_years.values.sum /
            average_filed_prosecutions_per_prosecutor_monthly_by_years.keys.size.to_f
        end
    end

    def average_filed_prosecutions_per_prosecutor_yearly_by_years
      @average_filed_prosecutoions_per_prosecutor_yearly_by_years ||=
        self.class.indicators[id].try { |e| e[:average_filed_prosecutions_per_prosecutor_yearly_by_years] }
    end

    def average_filed_prosecutions_per_prosecutor_yearly
      @average_filed_prosecutions_per_prosecutor_yearly ||=
        if average_filed_prosecutions_per_prosecutor_yearly_by_years.blank?
          nil
        else
          average_filed_prosecutions_per_prosecutor_yearly_by_years.values.sum /
            average_filed_prosecutions_per_prosecutor_yearly_by_years.keys.size.to_f
        end
    end

    def prosecutors_count_by_years
      @prosecutors_count_by_years ||= self.class.indicators[id].try { |e| e[:prosecutors_count_by_years] }
    end

    def to_indicators_chart_data
      years = [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019]
      key = ->(value) { "active_record.models.prosecutor.indicators.#{value}" }
      mapper = lambda do |data|
        break unless data

        years.map { |year| data[year] }
      end

      data =
        [
          {
            id: :convicted,
            name: I18n.t(key.call('average_convicted_people.office')),
            data: mapper.call(convicted_people_by_years)
          },
          {
            name: I18n.t(key.call("average_convicted_people.#{type}")),
            data: mapper.call(self.class.average_convicted_people_by_years_by_office_type[type]),
            dependent: :convicted
          },
          {
            id: :incoming_cases,
            name: I18n.t(key.call('average_incoming_cases_per_prosecutor.office')),
            data: mapper.call(average_incoming_cases_per_prosecutor_yearly_by_years),
            visible: false
          },
          {
            name: I18n.t(key.call("average_incoming_cases_per_prosecutor.#{type}")),
            data: mapper.call(self.class.average_incoming_cases_per_prosecutor_yearly_by_years_by_office_type[type]),
            dependent: :incoming_cases
          },
          {
            id: :filed_prosecutions,
            name: I18n.t(key.call('average_filed_prosecutions_per_prosecutor.office')),
            data: mapper.call(average_filed_prosecutions_per_prosecutor_yearly_by_years),
            visible: false
          },
          {
            name: I18n.t(key.call("average_filed_prosecutions_per_prosecutor.#{type}")),
            data:
              mapper.call(self.class.average_filed_prosecutions_per_prosecutor_yearly_by_years_by_office_type[type]),
            dependent: :filed_prosecutions
          }
        ].select { |values| values[:data].present? }

      { years: years, data: data }
    end

    class_methods do
      def indicators
        @indicators ||= prepare_indicators
      end

      def average_convicted_people_yearly_by_office_type
        @average_convicted_people_yearly_by_office_type ||=
          Office.all.group_by(&:type).each.with_object({}) do |(type, offices), hash|
            values = offices.map(&:average_convicted_people_yearly).compact

            next if values.blank? || type.in?(%w[general specialized])

            hash[type] = values.sum / offices.size.to_f
          end
      end

      def average_convicted_people_by_years_by_office_type
        @average_convicted_people_by_years_by_office_type ||=
          Office.all.group_by(&:type).each.with_object({}) do |(type, offices), hash|
            sums =
              offices.map(&:convicted_people_by_years).each.with_object({}) do |values, result|
                result.merge!(values) { |_, a, b| a && b ? a + b : a || b }
              end

            next if sums.blank? || type.in?(%w[general specialized])

            hash[type] = sums.each.with_object({}) { |(year, sum), result| result[year] = sum / offices.count.to_f }
          end
      end

      def average_incoming_cases_per_prosecutor_yearly_by_office_type
        @average_incoming_cases_per_prosecutor_yearly_by_office_type ||=
          Office.all.group_by(&:type).each.with_object({}) do |(type, offices), hash|
            values = offices.map(&:average_incoming_cases_per_prosecutor_yearly).compact

            next if values.blank? || type.in?(%w[general specialized])

            hash[type] = values.sum / offices.size.to_f
          end
      end

      def average_incoming_cases_per_prosecutor_yearly_by_years_by_office_type
        @average_incoming_cases_per_prosecutor_yearly_by_years_by_office_type ||=
          Office.all.group_by(&:type).each.with_object({}) do |(type, offices), hash|
            sums =
              offices.map(&:average_incoming_cases_per_prosecutor_yearly_by_years).each.with_object(
                {}
              ) { |values, result| result.merge!(values || {}) { |_, a, b| a && b ? a + b : a || b } }

            next if sums.blank? || type.in?(%w[general specialized])

            hash[type] = sums.each.with_object({}) { |(year, sum), result| result[year] = sum / offices.count.to_f }
          end
      end

      def average_filed_prosecutions_per_prosecutor_yearly_by_office_type
        @average_filed_prosecutions_per_prosecutor_yearly_by_office_type ||=
          Office.all.group_by(&:type).each.with_object({}) do |(type, offices), hash|
            values = offices.map(&:average_filed_prosecutions_per_prosecutor_yearly).compact

            next if values.blank? || type.in?(%w[general specialized])

            hash[type] = values.sum / offices.size.to_f
          end
      end

      def average_filed_prosecutions_per_prosecutor_yearly_by_years_by_office_type
        @average_filed_prosecutions_per_prosecutor_yearly_by_years_by_office_type ||=
          Office.all.group_by(&:type).each.with_object({}) do |(type, offices), hash|
            sums =
              offices.map(&:average_filed_prosecutions_per_prosecutor_yearly_by_years).each.with_object(
                {}
              ) { |values, result| result.merge!(values || {}) { |_, a, b| a && b ? a + b : a || b } }

            next if sums.blank? || type.in?(%w[general specialized])

            hash[type] = sums.each.with_object({}) { |(year, sum), result| result[year] = sum / offices.count.to_f }
          end
      end

      private

      def prepare_indicators
        indicators = {}

        lines = CSV.readlines(Rails.root.join('data', 'offices-incoming-cases.csv'))
        parse_indicators_lines(lines) do |office, row|
          indicators[office.id] = {
            average_incoming_cases_per_prosecutor_monthly_by_years:
              row[2..11].reverse.each.with_index.with_object({}) { |(value, i), values| values[2010 + i] = value.to_f },
            average_incoming_cases_per_prosecutor_yearly_by_years:
              row[13..23].reverse.each.with_index.with_object({}) { |(value, i), values| values[2010 + i] = value.to_f }
          }
        end

        lines = CSV.readlines(Rails.root.join('data', 'offices-filed-prosecutions.csv'))
        parse_indicators_lines(lines) do |office, row|
          indicators[office.id].merge!(
            average_filed_prosecutions_per_prosecutor_monthly_by_years:
              row[2..11].reverse.each.with_index.with_object({}) { |(value, i), values| values[2010 + i] = value.to_f },
            average_filed_prosecutions_per_prosecutor_yearly_by_years:
              row[13..23].reverse.each.with_index.with_object({}) { |(value, i), values| values[2010 + i] = value.to_f }
          )
        end

        lines = CSV.readlines(Rails.root.join('data', 'offices-historical-prosecutors-counts.csv'))
        parse_indicators_lines(lines) do |office, row|
          indicators[office.id].merge!(
            prosecutors_count_by_years:
              row[2..11].reverse.each.with_index.with_object({}) { |(value, i), values| values[2010 + i] = value.to_f }
          )
        end

        indicators
      end

      def parse_indicators_lines(lines)
        lines[2..-1].each do |row|
          name = row[0..1].join(' ').gsub(/OP/, 'Okresná prokuratúra').gsub(/KP/, 'Krajská prokuratúra').strip

          office = ::Office.find_by!(name: name)

          yield(office, row)
        end
      end
    end
  end
end
