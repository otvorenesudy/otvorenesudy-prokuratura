# frozen_string_literal: true

module GenproGovSk
  module Decrees
    module Parser
      def self.parse(html, url:)
        Nokogiri.HTML(html).css('.tx-tempest-applications .govuk-table tbody tr').filter_map do |row|
          parse_row(row.css('td'), url:)
        end
      end

      # A decree's row: its link (or none on an empty listing), dates, file number and resolution.
      def self.parse_row(columns, url:)
        link = columns[0].css('a')[0]

        return unless link

        {
          url: "#{url}#{link[:href]}",
          number: link.text.strip.lines.first.strip,
          effective_on: parse_date(columns[1]),
          published_on: parse_date(columns[2]),
          file_number: columns[3].text.strip,
          resolution: columns[4].text.strip,
          means_of_resolution: columns[5].text.strip,
          file_type: link[:href][/\.([^.]+)$/, 1].downcase
        }
      end

      def self.parse_date(column)
        Date.strptime(column.text.strip.squeeze(' '), '%d. %m. %Y')
      end
      private_class_method :parse_row, :parse_date
    end
  end
end
