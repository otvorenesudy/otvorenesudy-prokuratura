module GenproGovSk
  module Declarations
    class Parser
      using UnicodeString

      def self.parse(html)
        document = Nokogiri.HTML(html)

        {
          year: document.css('.tx-tempest-applications > h3')[0].text.match(/rok (\d+)/)[1].to_i,
          lists:
            document
              .search('.idsk-table')
              .map do |table|
                caption = table.xpath('preceding-sibling::h3[1]').text.strip.presence

                next if caption == 'Príjmy a iné pôžitky'

                { category: caption, items: parse_items(table) }
              end
              .compact,
          incomes: nil, # parse_incomes(document),
          statements:
            document
              .css('.tx-tempest-applications > .content > ol.govuk-label > li')
              .map { |li| li.text.strip.presence }
              .compact
        }
      end

      def self.parse_items(table)
        Table.parse(
          table,
          parser_factory:
            lambda do |heading|
              case heading
              when ['popis veci', 'dátum nadobudnutia'], ['druh záväzku', 'dátum nadobudnutia'], [
                     'popis veci',
                     'dátum nadobudnutia',
                     'cena obvyklá'
                   ]
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
                   ], ['názov/popis', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obvyklá', 'cena obstarania'], [
                     'popis majetku',
                     'dôvod nadobudnutia',
                     'dátum nadobudnutia',
                     'cena obvyklá',
                     'cena obstarania'
                   ], [
                     'popis práva',
                     'právny dôvod nadobudnutia',
                     'dátum nadobudnutia',
                     'cena obvyklá',
                     'cena obstarania'
                   ], ['popis práva', 'právny dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obvyklá'], [
                     'popis majetku',
                     'dôvod nadobudnutia',
                     'dátum nadobudnutia',
                     'cena obvyklá'
                   ], ['popis majetku', 'dôvod nadobudnutia', 'dátum nadobudnutia'], [
                     'popis práva',
                     'právny dôvod nadobudnutia',
                     'dátum nadobudnutia'
                   ]
                lambda do |row|
                  {
                    description: row.css('td')[0].text.strip.presence,
                    acquisition_reason: row.css('td')[1].text.strip.presence,
                    acquisition_date: row.css('td')[2].text.strip.presence,
                    price: row.css('td')[3].try { |e| e.text.strip.presence },
                    procurement_price: row.css('td')[4].try { |e| e.text.strip.presence }
                  }
                end
              when ['popis majetku', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obstarania'], [
                     'popis práva',
                     'právny dôvod nadobudnutia',
                     'dátum nadobudnutia',
                     'cena obstarania'
                   ]
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
        table =
          document.xpath('//table.idsk-table[preceding-sibling::h3[contains(text(), "Príjmy a iné pôžitky")]]').try(
            :parent
          )

        return unless table

        Table.parse(
          table,
          parser_factory:
            lambda do |heading|
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
          heading = table.css('thead > tr:nth-child(1) > th').map { |th| th.text.downcase.strip.presence }.compact
          parser = parser_factory.call(heading)

          raise ArgumentError.new("No parser for #{heading}") unless parser

          items = table.search('tbody > tr').map { |row| parser.call(row) }

          items.select { |item| item.try(:compact).present? }
        end
      end
    end
  end
end
