module GenproGovSk
  module Offices
    module Parser
      EMPLOYEE_POSITIONS =
        [
          'generálny prokurátor Slovenskej republiky',
          'krajská prokurátorka',
          'krajský prokurátor',
          'námestník generálneho prokurátora Slovenskej republiky',
          'námestník krajskej prokurátorky, - netrestný úsek',
          'námestník krajskej prokurátorky, - trestný úsek',
          'námestník krajskej prokurátorky',
          'námestník krajského prokurátora - trestný úsek',
          'námestník krajského prokurátora',
          'námestník krajského prokurátora pre netrestný úsek,',
          'námestník krajského prokurátora, - netrestný úsek',
          'námestník krajského prokurátora, - trestný úsek',
          'námestník okresnej prokurátorky',
          'námestník okresného prokurátora',
          'námestník okresného prokurátora JUDr., - netrestný úsek',
          'námestník okresného prokurátora, - trestný úsek',
          'námestníčka generálneho prokurátora Slovenskej republiky pre netrestný úsek',
          'námestníčka krajskej prokurátorky, - netrestný úsek',
          'námestníčka krajskej prokurátorky',
          'námestníčka krajského prokurátora, - netrestný úsek',
          'námestníčka krajského prokurátora, - trestný úsek',
          'námestníčka krajského prokurátora',
          'námestníčka okresnej prokurátorky',
          'námestníčka okresného prokurátora',
          'námestníčka okresného prokurátora, - netrestný úsek',
          'okresná prokurátorka',
          'okresný prokurátor',
          'poverená výkonom funkcie zástupcu riaditeľa medzinárodného odboru',
          'poverený výkonom funkcie námestníka krajského prokurátora pre trestný úsek',
          'poverený výkonom funkcie námestníka okresného prokurátora',
          'poverený výkonom funkcie okresného prokurátora',
          'poverený výkonom funkcie vedúceho oddelenia právneho zastupovania štátu pred súdmi a inými orgánmi',
          'prvá námestníčka generálneho prokurátora Slovenskej republiky',
          'riaditeľ medzinárodného odboru',
          'riaditeľ netrestného odboru',
          'riaditeľ odboru ekonomickej kriminality ÚŠP GP SR',
          'riaditeľ odboru všeobecnej kriminality ÚŠP GP SR',
          'riaditeľ registra trestov',
          'riaditeľ trestného odboru',
          'riaditeľka Kancelárie generálneho prokurátora Slovenskej republiky',
          'riaditeľka ekonomického odboru',
          'riaditeľka odboru informatiky',
          'riaditeľka odboru legislatívy a ústavného práva',
          'riaditeľka osobného úradu',
          'vedúca oddelenia hospodárskej kriminality odboru ekonomickej kriminality ÚŠP GP SR',
          'vedúca oddelenia rozpočtu a verejného obstarávania',
          'vedúca oddelenia služobných vzťahov prokurátorov, právnych čakateľov prokuratúry a zamestnancov prokuratúry',
          'vedúca oddelenia správnych činností',
          'vedúca oddelenia vzdelávania a ďalších činností',
          'vedúca oddelenia ústavného práva',
          'vedúca organizačno-kontrolného oddelenia',
          'vedúca referátu ochrany utajovaných skutočností',
          'vedúca referátu správy registratúry',
          'vedúci oddelenia extrémistickej kriminality ÚŠP GP SR',
          'vedúci oddelenia hospodárskej správy',
          'vedúci oddelenia koncepcie a rozvoja IS RT a mikrofilmovej archivácie a indexácie',
          'vedúci oddelenia korupcie odboru všeobecnej kriminality ÚŠP GP SR',
          'vedúci oddelenia legislatívy',
          'vedúci oddelenia majetkovej kriminality odboru ekonomickej kriminality ÚŠP GP SR',
          'vedúci oddelenia majetkovej kriminality trestného odboru',
          'vedúci oddelenia medzinárodného práva verejného a európskych záležitostí',
          'vedúci oddelenia násilnej a všeobecnej kriminality trestného odboru',
          'vedúci oddelenia organizovaného zločinu, terorizmu a medzinárodnej kriminality ÚŠP GP SR',
          'vedúci oddelenia prevádzky informačného systému registra trestov',
          'vedúci oddelenia právneho styku s cudzinou a extradícií',
          'vedúci oddelenia stratégie a rozvoja IS a rezortnej štatistiky, vedúci oddelenia prevádzky IS, informačnej bezpečnosti a zverejňovania',
          'vedúci prieskumného oddelenia',
          'vedúci referátu vnútorného auditu',
          'zástupca riaditeľa netrestného odboru',
          'zástupca riaditeľa trestného odboru',
          'zástupca riaditeľky odboru informatiky',
          'zástupca špeciálneho prokurátora',
          'zástupkyňa riaditeľa registra trestov',
          'zástupkyňa riaditeľky osobného úradu',
          'špeciálny prokurátor',
          'špeciálny prokurátor - námestník generálneho prokurátora'
        ].sort_by(&:size).reverse.freeze

      def self.parse(html)
        document = Nokogiri.HTML(html)

        data = {
          name: normalize(document.css('.contentPage > h3').text),
          employees:
            document.css('.tab-kontakt:nth-of-type(2) tr')[1..-1].map do |row|
              text = row.css('td').map { |e| normalize(e.text).presence }.compact.join('<>')

              next unless text.present?

              position =
                EMPLOYEE_POSITIONS.select do |position|
                  next unless text.include?(position)

                  text.gsub!(/#{position}[[:space:]]*(<>)?/, '')

                  break position
                end

              raise StandardError.new("Unkown position for employee: #{text}") unless position

              name, phone = normalize(text).split('<>').map { |e| normalize(e) }

              _, suffix_to_position = *name.match(/(?<suffix>- (ne)?trestný úsek)\z/)

              {
                name: suffix_to_position ? normalize(name.gsub(suffix_to_position, '')) : name,
                position: normalize("#{position} #{suffix_to_position}"),
                phone: phone
              }
            end.compact
        }

        data.merge(parse_contact(document))
      end

      class << self
        private

        def normalize(string)
          string&.gsub(/,{2,}/, ',')&.gsub(/(\A,|,\z)/, '')&.gsub(/(\A[[:space:]]+|[[:space:]]+\z)/, '')&.gsub(
            /[[:space:]]{3,}/,
            ', '
          )&.gsub(/[[:space:]]+/, ' ')&.gsub(/,\z/, '')
        end

        def parse_contact(document)
          registry_phone =
            document.css('.tab-kontakt:nth-of-type(1) tr:nth-of-type(2) td:nth-of-type(1) p').text.match(/\((.+)\)/)

          remove_excessive_redundant_columns_from_first_contact_table(document)

          data = {
            address:
              document.css('.tab-kontakt:nth-of-type(1) tr:nth-of-type(1) td:nth-of-type(1) p').map do |e|
                normalize(e.text)
              end,
            phone:
              normalize(
                document.css('.tab-kontakt:nth-of-type(1) tr:nth-of-type(1) td:nth-of-type(2) p:nth-of-type(1)').text
              ),
            registry: {
              phone: registry_phone ? normalize(registry_phone[1]) : nil,
              hours:
                %i[monday tuesday wednesday thursday friday].map.with_index do |day, i|
                  {
                    day =>
                      document.css(".tab-kontakt:nth-of-type(1) tr:nth-of-type(#{i + 3}) td")[1..2].map do |e|
                        normalize(e.text).presence
                      end.compact.join(' – ').gsub(/\./, ':')
                  }
                end.inject(:merge)
            }
          }

          document.css('.tab-kontakt:nth-of-type(1) tr:nth-of-type(1) td:nth-of-type(2) p')[1..-1].map do |line|
            if line.text.match(/e\-mail:/)
              next { email: normalize(line.css('a')[0][:href].match(/\Amailto:(.+)\z/)[1]) }
            end

            next { fax: normalize(line.text) } if line.text.match(/fax:/)

            if line.text.match(/elektronická podateľňa:/)
              next { electronic_registry: normalize(line.css('a')[0][:href]) }
            end
          end.compact.inject(:merge).merge(data)
        end

        def remove_excessive_redundant_columns_from_first_contact_table(document)
          lines = document.css('.tab-kontakt:nth-of-type(1) tr').size

          return unless lines > 7

          redundant_lines_range = 2..(2 + (lines - 7) - 1)

          document.css('.tab-kontakt:nth-of-type(1) tr')[redundant_lines_range].map(&:remove)
        end
      end
    end
  end
end
