module GenproGovSk
  module Offices
    module Parser
      def self.parse(html)
        document = Nokogiri.HTML(html)

        unknown = []
        name = normalize(document.css('.tx-tempest-contacts > h1').text)

        data = {
          name: name,
          type: type_by(name),
          employees:
            document.css('.tx-tempest-contacts .table-responsive:nth-of-type(2) .gp-table tr')[1..-1]
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
          contact_table = document.css('.tx-tempest-contacts .table-responsive:nth-of-type(1) .gp-table')

          location =
            contact_table.css('tr:nth-child(1) td:nth-child(1)').text.gsub(/\t+/, "\t").gsub('\s+', ' ').split("\t")

          address = location[location.size - 2]
          _, zipcode, city = *location[location.size - 1].match(/\A(\d{3}[[:space:]]*\d{2})[[:space:]]{0,}(.+)\z/)

          address = normalize(address)
          zipcode = normalize(zipcode)
          city = normalize(city)

          contact = contact_table.css('tr:nth-child(1) td:nth-child(2)').text.gsub(/\t+/, "\n").gsub('\s+', ' ')
          _, phone = *contact.match(/tel\.{0,1}:(.+)$/)
          _, fax = *contact.match(/fax:(.+)$/)
          _, email = *contact.match(/e-mail:(.+)$/)
          _, _, electronic_registry = *contact.match(/(edesk adresa|elektronická podateľňa):(.+)$/)

          data = {
            address: address,
            zipcode: zipcode,
            city: city,
            phone: normalize(phone),
            fax: normalize(fax),
            email: normalize(email),
            electronic_registry: normalize(electronic_registry),
            registry: {
              note: normalize(document.css('.tx-tempest-contacts > p.text-justify').text),
              phone: nil,
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
