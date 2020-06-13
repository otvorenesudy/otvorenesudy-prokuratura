module GenproGovSk
  module Offices
    module Parser
      def self.parse(html)
        document = Nokogiri.HTML(html)

        data = {
          name: strip(document.css('.contentPage > h3').text),
          employees:
            document.css('.tab-kontakt:nth-of-type(2) tr')[1..-1].map do |row|
              columns = row.css('td')
              name = strip(columns[0].text)

              next unless name.present?

              {
                name: name,
                position: columns.size == 3 ? strip(columns[1].text) : nil,
                phone: columns.size == 3 ? strip(columns[2].text) : strip(columns[1].text)
              }
            end.compact
        }

        data.merge(parse_contact(document))
      end

      class << self
        private

        def strip(string)
          string.gsub(/(\A[[:space:]]+|[[:space:]]+\z)/, '')
        end

        def parse_contact(document)
          registry_phone =
            document.css('.tab-kontakt:nth-of-type(1) tr:nth-of-type(2) td:nth-of-type(1) p').text.match(/\((.+)\)/)

          data = {
            address:
              document.css('.tab-kontakt:nth-of-type(1) tr:nth-of-type(1) td:nth-of-type(1) p').map do |e|
                strip(e.text)
              end,
            phone:
              strip(
                document.css('.tab-kontakt:nth-of-type(1) tr:nth-of-type(1) td:nth-of-type(2) p:nth-of-type(1)').text
              ),
            registry: {
              phone: registry_phone ? strip(registry_phone[1]) : nil,
              hours:
                %i[monday tuesday wednesday thursday friday].map.with_index do |day, i|
                  {
                    day =>
                      document.css(".tab-kontakt:nth-of-type(1) tr:nth-of-type(#{i + 3}) td")[1..2].map do |e|
                        strip(e.text).gsub(/\./, ':')
                      end
                  }
                end.inject(:merge)
            }
          }

          document.css('.tab-kontakt:nth-of-type(1) tr:nth-of-type(1) td:nth-of-type(2) p')[1..-1].map do |line|
            next { email: strip(line.css('a')[0][:href].match(/\Amailto:(.+)\z/)[1]) } if line.text.match(/e\-mail:/)

            next { fax: strip(line.text) } if line.text.match(/fax:/)

            next { electronic_registry: strip(line.css('a')[0][:href]) } if line.text.match(/elektronická podateľňa:/)
          end.compact.inject(:merge).merge(data)
        end
      end
    end
  end
end
