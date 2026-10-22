# frozen_string_literal: true

module Offices
  module Indicators
    extend ActiveSupport::Concern

    def convicted_people_by_years
      @convicted_people_by_years ||=
        statistics.where(metric: :convicted_all).where.not(paragraph: nil).group(:year).order(year: :asc).sum(:count)
    end

    def average_convicted_people_yearly
      @average_convicted_people_yearly ||=
        if convicted_people_by_years.blank?
          nil
        else
          convicted_people_by_years.values.sum / convicted_people_by_years.keys.size.to_f
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

    def average_filed_prosecutions_per_prosecutor_yearly_by_years
      @average_filed_prosecutions_per_prosecutor_yearly_by_years ||=
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

    def incoming_cases_by_years
      @incoming_cases_by_years ||= self.class.indicators[id].try { |e| e[:incoming_cases_by_years] }
    end

    def average_incoming_cases_yearly
      @average_incoming_cases_yearly ||=
        if incoming_cases_by_years.blank?
          nil
        else
          incoming_cases_by_years.values.sum / incoming_cases_by_years.keys.size.to_f
        end
    end

    def rest_cases_by_years
      @rest_cases_by_years ||= self.class.indicators[id].try { |e| e[:rest_cases_by_years] }
    end

    def average_rest_cases_yearly
      @average_rest_cases_yearly ||=
        rest_cases_by_years.blank? ? nil : rest_cases_by_years.values.sum / rest_cases_by_years.keys.size.to_f
    end

    def average_ratio_of_rest_to_incoming_cases_yearly
      @average_ratio_of_rest_to_incoming_cases_yearly ||= average_rest_cases_yearly / average_incoming_cases_yearly.to_f
    end

    def average_ratio_of_rest_to_incoming_cases_by_years
      @average_ratio_of_rest_to_incoming_cases_by_years ||=
        if rest_cases_by_years.blank?
          nil
        else
          rest_cases_by_years
            .each
            .with_object({}) { |(year, count), hash| hash[year] = count / incoming_cases_by_years[year].to_f }
        end
    end

    # The indicators the office's chart draws, each beside the average of the offices of its type: the translation key,
    # the office's values by year and the class method with the averages by type. Only the first shows at first.
    CHART_INDICATORS = {
      convicted: %i[
        average_convicted_people convicted_people_by_years average_convicted_people_by_years_by_office_type
      ],
      incoming_cases_per_prosecutor: %i[
        average_incoming_cases_per_prosecutor
        average_incoming_cases_per_prosecutor_yearly_by_years
        average_incoming_cases_per_prosecutor_by_years_by_office_type
      ],
      filed_prosecutions_per_prosecutor: %i[
        average_filed_prosecutions_per_prosecutor
        average_filed_prosecutions_per_prosecutor_yearly_by_years
        average_filed_prosecutions_per_prosecutor_by_years_by_office_type
      ],
      prosecutors_count: %i[
        prosecutors_count prosecutors_count_by_years average_prosecutors_count_by_years_by_office_type
      ],
      rest_cases: %i[rest_cases rest_cases_by_years average_rest_cases_by_years_by_office_type],
      incoming_cases: %i[incoming_cases incoming_cases_by_years average_incoming_cases_by_years_by_office_type],
      ratio_of_rest_to_incoming_cases: %i[
        ratio_of_rest_to_incoming_cases
        average_ratio_of_rest_to_incoming_cases_by_years
        average_ratio_of_rest_to_incoming_cases_by_years_by_office_type
      ]
    }.freeze

    CHART_YEARS = (2010..2019).to_a.freeze

    def to_indicators_chart_data
      data =
        CHART_INDICATORS.flat_map do |id, (key, values, averages)|
          name = "active_record.models.prosecutor.indicators.#{key}"
          office = { id:, name: I18n.t("#{name}.office"), data: chart_values(public_send(values)) }
          office[:visible] = false unless id == :convicted
          average = { name: I18n.t("#{name}.#{type}"), data: chart_values(self.class.public_send(averages)[type]) }

          [office, average.merge(dependent: id)]
        end

      { years: CHART_YEARS, data: data.select { |series| series[:data].present? } }
    end

    def chart_values(values)
      CHART_YEARS.map { |year| values[year] } if values.present?
    end

    class_methods do
      # The indicators and their averages are read from the datasets once per process; this reads them again.
      def reset_indicators!
        instance_variables.each do |name|
          remove_instance_variable(name) if name.start_with?('@average', '@indicators', '@offices_map')
        end
      end

      def offices_map
        @offices_map ||=
          Office.find_each.with_object({}) do |office, acc|
            [office.id, office.name, *office.synonyms].compact.each { |name| acc[name] = office }
          end
      end

      def indicators
        @indicators ||= prepare_indicators
      end

      def average_convicted_people_yearly_by_office_type
        @average_convicted_people_yearly_by_office_type ||=
          compute_yearly_indicators_average_by_office_type(:average_convicted_people_yearly)
      end

      def average_convicted_people_by_years_by_office_type
        @average_convicted_people_by_years_by_office_type ||=
          compute_indicators_average_by_years_by_office_type(:convicted_people_by_years)
      end

      def average_incoming_cases_per_prosecutor_yearly_by_office_type
        @average_incoming_cases_per_prosecutor_yearly_by_office_type ||=
          compute_yearly_indicators_average_by_office_type(:average_incoming_cases_per_prosecutor_yearly)
      end

      def average_incoming_cases_per_prosecutor_by_years_by_office_type
        @average_incoming_cases_per_prosecutor_by_years_by_office_type ||=
          compute_indicators_average_by_years_by_office_type(:average_incoming_cases_per_prosecutor_yearly_by_years)
      end

      def average_filed_prosecutions_per_prosecutor_yearly_by_office_type
        @average_filed_prosecutions_per_prosecutor_yearly_by_office_type ||=
          compute_yearly_indicators_average_by_office_type(:average_filed_prosecutions_per_prosecutor_yearly)
      end

      def average_filed_prosecutions_per_prosecutor_by_years_by_office_type
        @average_filed_prosecutions_per_prosecutor_by_years_by_office_type ||=
          compute_indicators_average_by_years_by_office_type(:average_filed_prosecutions_per_prosecutor_yearly_by_years)
      end

      def average_prosecutors_count_by_years_by_office_type
        @average_prosecutors_count_by_years_by_office_type ||=
          compute_indicators_average_by_years_by_office_type(:prosecutors_count_by_years)
      end

      def average_rest_cases_yearly_by_office_type
        @average_rest_cases_yearly_by_office_type ||=
          compute_yearly_indicators_average_by_office_type(:average_rest_cases_yearly)
      end

      def average_rest_cases_by_years_by_office_type
        @average_rest_cases_by_years_by_office_type ||=
          compute_indicators_average_by_years_by_office_type(:rest_cases_by_years)
      end

      def average_incoming_cases_yearly_by_office_type
        @average_incoming_cases_yearly_by_office_type ||=
          compute_yearly_indicators_average_by_office_type(:average_incoming_cases_yearly)
      end

      def average_incoming_cases_by_years_by_office_type
        @average_incoming_cases_by_years_by_office_type ||=
          compute_indicators_average_by_years_by_office_type(:incoming_cases_by_years)
      end

      def average_ratio_of_rest_to_incoming_cases_by_years_by_office_type
        @average_ratio_of_rest_to_incoming_cases_by_years_by_office_type ||=
          compute_indicators_average_by_years_by_office_type(:average_ratio_of_rest_to_incoming_cases_by_years)
      end

      private

      def prepare_indicators
        indicators = Hash.new { |hash, id| hash[id] = {} }

        read_yearly_indicator(indicators, 'offices-incoming-cases', 13..23,
                              :average_incoming_cases_per_prosecutor_yearly_by_years)
        read_yearly_indicator(indicators, 'offices-filed-prosecutions', 13..23,
                              :average_filed_prosecutions_per_prosecutor_yearly_by_years)
        read_yearly_indicator(indicators, 'offices-historical-prosecutors-counts', 2..11, :prosecutors_count_by_years)
        read_cases(indicators)

        indicators.to_a.to_h
      end

      # A dataset of an indicator by year: the columns hold the years backwards from 2010 on.
      def read_yearly_indicator(indicators, dataset, columns, key)
        parse_indicators_lines(CSV.readlines(Rails.root.join("data/#{dataset}.csv"))) do |office, row|
          indicators[office.id][key] = row[columns].reverse.each_with_index.to_h { |value, i| [2010 + i, value.to_f] }
        end
      end

      # The incoming and the unresolved cases by year from 2006, a column per office.
      def read_cases(indicators)
        lines = CSV.readlines(Rails.root.join('data/offices-rest-vs-incoming-cases.csv'))
        offices = lines[0][3..].map do |value|
          offices_map[value.start_with?('KP') ? value.sub('KP', 'Krajská prokuratúra') : "Okresná prokuratúra #{value}"]
        end

        { incoming_cases_by_years: lines[1..14], rest_cases_by_years: lines[15..28] }.each do |key, rows|
          rows.each_with_index do |row, i|
            row[3..].each_with_index { |value, j| (indicators[offices[j].id][key] ||= {})[2006 + i] = value.to_i }
          end
        end
      end

      def parse_indicators_lines(lines)
        lines[2..].each do |row|
          name = row[0..1].join(' ').gsub('OP', 'Okresná prokuratúra').gsub('KP', 'Krajská prokuratúra').strip

          office = offices_map[name]

          yield(office, row)
        end
      end

      def compute_yearly_indicators_average_by_office_type(metric)
        Office
          .all
          .group_by(&:type)
          .each
          .with_object({}) do |(type, offices), hash|
            values = offices.map(&metric).compact

            next if values.blank? || type.in?(%w[general specialized])

            hash[type] = values.sum / offices.size.to_f
          end
      end

      def compute_indicators_average_by_years_by_office_type(metric)
        Office
          .all
          .group_by(&:type)
          .each
          .with_object({}) do |(type, offices), hash|
            sums =
              offices
              .map(&metric)
              .each
              .with_object({}) { |values, result| result.merge!(values || {}) { |_, a, b| a + b } }

            next if sums.blank? || type.in?(%w[general specialized])

            hash[type] = sums.each.with_object({}) { |(year, sum), result| result[year] = sum / offices.count.to_f }
          end
      end
    end
  end
end
