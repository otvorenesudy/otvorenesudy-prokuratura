module GenproGovSk
  module Offices
    module Parser
      def self.parse(html)
        document = Nokogiri.HTML(html)

        unknown = []
        name = normalize(document.css('.tx-tempest-contacts > h1').text)

        employee_table_rows = document.css(table_selector(2)).css('tr')

        data = {
          name: name,
          type: type_by(name),
          employees:
            (employee_table_rows[1..-1] || [])
              .map
              .with_index do |row, rank|
                next if row.text.gsub(/[[:space:]]*/, '').blank?

                name_parts = parse_name(row.css('td:nth-child(1)').text)

                next if name_parts[:value].blank?

                position = row.css('td:nth-child(2)').text
                phone = normalize(row.css('td:nth-child(3)').text)

                {
                  name: name_parts[:value],
                  name_parts: name_parts.except(:value),
                  position: position,
                  rank: rank + 1,
                  phone: phone
                }
              end
              .compact
        }

        warn "Unknown positions: \n#{unknown.join("\n")}" if unknown.any?

        data.merge(parse_contact(document))
      end

      class << self
        private

        def table_selector(n)
          ".tx-tempest-contacts .table-responsive:nth-of-type(#{n}) .gp-table, .tx-tempest-contacts figure.table:nth-of-type(#{n}) .gp-table"
        end

        def normalize(string)
          string
            &.gsub(/,{2,}/, ',')
            &.gsub(/(\A,|,\z)/, '')
            &.gsub(/(\A[[:space:]]+|[[:space:]]+\z)/, '')
            &.gsub(/[[:space:]]{3,}/, ', ')
            &.gsub(/[[:space:]]+/, ' ')
            &.gsub(/,\z/, '')
        end

        def parse_contact(document)
          contact_table = document.css(table_selector(1)).first

          # Get location from first cell, split by line breaks
          location_cell = contact_table.css('tr:nth-child(1) td:nth-child(1)')
          location_parts = location_cell.inner_html.split(/<br\s*\/?>/).map { |part| Nokogiri::HTML(part).text.strip }
          
          # Structure: [Office name, Address, Zipcode City]
          address = location_parts[-2]
          zipcode_city = location_parts[-1]
          _, zipcode, city = *zipcode_city.match(/\A(\d{3}[[:space:]]*\d{2})[[:space:]]{1,}(.+)\z/) if zipcode_city

          address = normalize(address)
          zipcode = normalize(zipcode)
          city = normalize(city)

          # Get contact info from second cell, split by line breaks
          contact_cell = contact_table.css('tr:nth-child(1) td:nth-child(2)')
          contact_parts = contact_cell.inner_html.split(/<br\s*\/?>/).map { |part| Nokogiri::HTML(part).text.strip }
          
          phone = nil
          fax = nil
          email = nil
          electronic_registry = nil
          
          contact_parts.each do |part|
            if part =~ /^tel\.{0,1}:\s*(.+)$/
              phone = $1
            elsif part =~ /^fax:\s*(.+)$/
              fax = $1
            elsif part =~ /^e-mail:\s*(.+)$/
              email = $1
            elsif part =~ /^(edesk adresa|elektronická podateľňa):\s*(.+)$/
              electronic_registry = $2
            end
          end

          registry_header = contact_table.css('tr').find { |tr| tr.text =~ /podateľňa.*úradné hodiny/ }
          registry_phone =
            if registry_header
              _, phones = *registry_header.text.match(/\(([^)]+)\)/)
              normalize(phones)
            end

          {
            address: address,
            zipcode: zipcode,
            city: city,
            phone: normalize(phone),
            fax: normalize(fax),
            email: normalize(email),
            electronic_registry: normalize(electronic_registry),
            registry: {
              note: normalize(document.css('.tx-tempest-contacts > p.text-justify').text),
              phone: registry_phone,
              hours:
                %i[monday tuesday wednesday thursday friday]
                  .map
                  .with_index do |day, i|
                    {
                      day =>
                        contact_table.css("tr:nth-of-type(#{i + 3}) td")[1..2]
                          .map { |e| normalize(e.text).presence }
                          .compact
                          .join(' – ')
                          .gsub(/\./, ':')
                    }
                  end
                  .inject(:merge)
            }
          }
        end

        def type_by(name)
          return :general if name.downcase =~ /generálna prokuratúra/
          return :specialized if name.downcase =~ /úrad špeciálnej prokuratúry/
          return :regional if name.downcase =~ /krajská/
          return :district if name.downcase =~ /okresná/
        end

        def parse_name(value)
          ::Legacy::Normalizer.partition_person_name(value)
        end
      end
    end
  end
end
