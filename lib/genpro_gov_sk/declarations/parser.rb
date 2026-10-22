# frozen_string_literal: true

module GenproGovSk
  module Declarations
    class Parser
      using UnicodeString

      THINGS = %i[description acquisition_date price].freeze
      ASSETS = %i[description acquisition_reason acquisition_date price procurement_price share_size].freeze
      SHARES = %i[description acquisition_reason acquisition_date share_size].freeze
      PURCHASES = %i[description acquisition_reason acquisition_date procurement_price].freeze

      # What a table's columns hold, by its heading: genpro.gov.sk's forms changed over the years.
      COLUMNS = {
        ['popis veci', 'dátum nadobudnutia'] => THINGS,
        ['druh záväzku', 'dátum nadobudnutia'] => THINGS,
        ['popis veci', 'dátum nadobudnutia', 'cena obvyklá'] => THINGS,
        ['názov/popis', 'dôvod nadobudnutia', 'dátum nadobudnutia'] => ASSETS,
        ['názov/popis', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obvyklá', 'cena obstarania'] => ASSETS,
        ['popis majetku', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obvyklá', 'cena obstarania'] => ASSETS,
        ['popis práva', 'právny dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obvyklá', 'cena obstarania'] => ASSETS,
        ['popis práva', 'právny dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obvyklá'] => ASSETS,
        ['popis majetku', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obvyklá'] => ASSETS,
        ['popis majetku', 'dôvod nadobudnutia', 'dátum nadobudnutia'] => ASSETS,
        ['popis práva', 'právny dôvod nadobudnutia', 'dátum nadobudnutia'] => ASSETS,
        [
          'názov/popis', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'cenaobvyklá', 'cena obstarania', 'veľkosťpodielu'
        ] => ASSETS,
        ['názov/popis', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'veľkosť podielu'] => SHARES,
        ['popis majetku', 'dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obstarania'] => PURCHASES,
        ['popis práva', 'právny dôvod nadobudnutia', 'dátum nadobudnutia', 'cena obstarania'] => PURCHASES
      }.freeze

      def self.parse(html)
        document = Nokogiri.HTML(html)

        {
          year: document.css('.tx-tempest-applications > h3')[0].text.match(/rok (\d+)/)[1].to_i,
          lists: parse_lists(document),
          incomes: nil,
          statements: document.css('.tx-tempest-applications > .content > ol.govuk-label > li')
                              .filter_map { |li| li.text.strip.presence }
        }
      end

      def self.parse_lists(document)
        document.search('.idsk-table').filter_map do |table|
          caption = table.xpath('preceding-sibling::h3[1]').text.strip.presence

          next if caption == 'Príjmy a iné pôžitky'

          { category: caption, items: parse_items(table) }
        end
      end

      def self.parse_items(table)
        heading = table.css('thead > tr:nth-child(1) > th').filter_map { |th| th.text.downcase.strip.presence }
        columns = COLUMNS[heading]

        raise ArgumentError, "No parser for #{heading}" unless columns

        table.search('tbody > tr').filter_map do |row|
          cells = row.css('td')
          item = columns.each_with_index.to_h { |key, index| [key, cells[index]&.text&.strip.presence] }

          item if item.compact.present?
        end
      end
    end
  end
end
