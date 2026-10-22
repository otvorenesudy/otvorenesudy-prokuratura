# frozen_string_literal: true

module GenproGovSk
  module Offices
    module Parser
      DAYS = %i[monday tuesday wednesday thursday friday].freeze

      # The lines of the contact cell, by what they start with; the last of a kind counts.
      CONTACTS = {
        phone: /^tel\.?:\s*(.+)$/,
        fax: /^fax:\s*(.+)$/,
        email: /^e-mail:\s*(.+)$/,
        electronic_registry: /^(?:edesk adresa|elektronická podateľňa):\s*(.+)$/
      }.freeze

      def self.parse(html)
        document = Nokogiri.HTML(html)
        name = normalize(document.css('.tx-tempest-contacts > h1').text)
        contacts = document.css(table_selector(1)).first

        {
          name:,
          type: type_by(name),
          employees: parse_employees(document.css(table_selector(2)).css('tr')[1..] || []),
          **parse_address(contacts),
          **parse_contacts(contacts),
          registry: parse_registry(document, contacts)
        }
      end

      class << self
        private

        def table_selector(index)
          ".tx-tempest-contacts .table-responsive:nth-of-type(#{index}) .gp-table, " \
            ".tx-tempest-contacts figure.table:nth-of-type(#{index}) .gp-table"
        end

        def normalize(string)
          return if string.nil?

          string
            .gsub(/,{2,}/, ',')
            .gsub(/(\A,|,\z)/, '')
            .gsub(/(\A[[:space:]]+|[[:space:]]+\z)/, '')
            .gsub(/[[:space:]]{3,}/, ', ')
            .gsub(/[[:space:]]+/, ' ')
            .delete_suffix(',')
        end

        # The staff table's rows: name, position and phone, ranked as listed.
        def parse_employees(rows)
          rows.each_with_index.filter_map do |row, index|
            next if row.text.gsub(/[[:space:]]*/, '').blank?

            name_parts = ::Legacy::Normalizer.partition_person_name(row.css('td:nth-child(1)').text)

            next if name_parts[:value].blank?

            {
              name: name_parts[:value],
              name_parts: name_parts.except(:value),
              position: row.css('td:nth-child(2)').text,
              rank: index + 1,
              phone: normalize(row.css('td:nth-child(3)').text)
            }
          end
        end

        # The lines of a cell in the contact table's first row.
        def cell_lines(contacts, column)
          contacts
            .css("tr:nth-child(1) td:nth-child(#{column})")
            .inner_html
            .split(%r{<br\s*/?>})
            .map { |part| Nokogiri::HTML(part).text.strip }
        end

        # The first cell's lines end with the street address, then the zip code and the city.
        def parse_address(contacts)
          *, address, zipcode_city = cell_lines(contacts, 1)
          _, zipcode, city = *zipcode_city&.match(/\A(\d{3}[[:space:]]*\d{2})[[:space:]]+(.+)\z/)

          { address: normalize(address), zipcode: normalize(zipcode), city: normalize(city) }
        end

        def parse_contacts(contacts)
          lines = cell_lines(contacts, 2)

          CONTACTS.transform_values { |pattern| normalize(lines.filter_map { |line| line[pattern, 1] }.last) }
        end

        # The registry's phones (in the heading of its hours) and its hours, a row a day from the table's third.
        def parse_registry(document, contacts)
          heading = contacts.css('tr').find { |row| row.text.match?(/podateľňa.*úradné hodiny/) }

          {
            note: normalize(document.css('.tx-tempest-contacts > p.text-justify').text),
            phone: (normalize(heading.text[/\(([^)]+)\)/, 1]) if heading),
            hours: DAYS.each_with_index.to_h { |day, index| [day, parse_hours(contacts, index + 3)] }
          }
        end

        def parse_hours(contacts, row)
          contacts
            .css("tr:nth-of-type(#{row}) td")[1..2]
            .filter_map { |cell| normalize(cell.text).presence }
            .join(' – ')
            .tr('.', ':')
        end

        def type_by(name)
          return :general if /generálna prokuratúra/.match?(name.downcase)
          return :specialized if /úrad špeciálnej prokuratúry/.match?(name.downcase)
          return :regional if /krajská/.match?(name.downcase)

          :district if /okresná/.match?(name.downcase)
        end
      end
    end
  end
end
