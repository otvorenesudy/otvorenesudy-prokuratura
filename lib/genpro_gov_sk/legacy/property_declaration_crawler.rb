module GenproGovSk
  module Legacy
    class PropertyDeclarationCrawler
      def self.crawl(url)
        html = Curl.get(url).body_str

        Parser.parse(html)
      end

      class Parser
        using UnicodeString

        def self.parse(html)
          document = Nokogiri.HTML(html)

          {
            year:
              document.at_css('#page > div.contentIntro > div.grid_9.contentPage > h3').text.match(/rok (\d+)/)[1].to_i,
            lists:
              document.search('.table_01').map do |table|
                caption = table.at_css('caption').text.strip.presence

                next if caption == 'Príjmy a iné pôžitky'

                { category: table.at_css('caption').text.strip.presence, items: parse_items(table) }
              end,
            incomes: parse_incomes(document),
            statements:
              document.css('#page > div.contentIntro > div.grid_9.contentPage > div > ol > li').map do |li|
                li.text.strip.presence
              end.compact
          }
        end

        def self.parse_items(table)
          Table.parse(
            table,
            parser_factory: lambda do |heading|
              case heading
              when ['popis veci', 'dátum nadobudnutia'], ['druh záväzku', 'dátum nadobudnutia'],
                   ['popis veci', 'dátum nadobudnutia', 'obvyklá cena']
                lambda do |row|
                  {
                    description: row.css('td')[0].text.strip.presence,
                    acquisition_date: row.css('td')[1].text.strip.presence,
                    price: row.css('td')[2].try { |e| e.text.strip.presence }
                  }
                end
              when ['názov/popis', 'dôvod nadobudnutia', 'dátum nadobudnutia'], [
                     'názov/popis',
                     'dôvod nadobudnutia',
                     'dátum nadobudnutia',
                     'cena obvyklá',
                     'cena obstarania'
                   ], ['názov/popis', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'obvyklá cena', 'cena obstarania'], [
                     'popis majetku',
                     'dôvod nadobudnutia',
                     'dátum nadobudnutia',
                     'obvyklá cena',
                     'cena obstarania'
                   ],
                   ['popis práva', 'právny dôvod nadobudnutia', 'dátum nadobudnutia', 'obvyklá cena', 'cena obstarania'],
                   ['popis práva', 'právny dôvod nadobudnutia', 'dátum nadobudnutia', 'obvyklá cena'],
                   ['popis majetku', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'obvyklá cena'], [
                     'popis majetku',
                     'dôvod nadobudnutia',
                     'dátum nadobudnutia'
                   ], ['popis práva', 'právny dôvod nadobudnutia', 'dátum nadobudnutia']
                lambda do |row|
                  {
                    description: row.css('td')[0].text.strip.presence,
                    acquisition_reason: row.css('td')[1].text.strip.presence,
                    acquisition_date: row.css('td')[2].text.strip.presence,
                    price: row.css('td')[3].try { |e| e.text.strip.presence },
                    procurement_price: row.css('td')[4].try { |e| e.text.strip.presence }
                  }
                end
              when ['popis majetku', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obstarania'], ['popis práva', 'právny dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obstarania']
                lambda do |row|
                  {
                    description: row.css('td')[0].text.strip.presence,
                    acquisition_reason: row.css('td')[1].text.strip.presence,
                    acquisition_date: row.css('td')[2].text.strip.presence,
                    procurement_price: row.css('td')[4].try { |e| e.text.strip.presence }
                  }
                end
              end
            end
          )
        end

        def self.parse_incomes(document)
          table = document.at_css('.table_01 > caption:contains(\'Príjmy a iné pôžitky\')').try(:parent)

          return unless table

          Table.parse(
            table,
            parser_factory: lambda do |heading|
              if heading == %w[popis príjmy]
                lambda do |row|
                  { description: row.css('td')[0].text.strip.presence, value: row.css('td')[1].text.strip.presence }
                end
              end
            end
          )
        end

        class Table
          def self.parse(table, parser_factory:)
            heading = table.css('tr.rowBlue_02 th').map { |th| th.text.downcase.strip.presence }.compact
            parser = parser_factory.call(heading)

            return raise("No parser for #{heading}") unless parser

            items = table.search('tr:not(.rowBlue_02)').map { |row| parser.call(row) }

            items.select { |item| item.try(:compact).present? }
          end
        end
      end
    end
  end
end
