module GenproGovSk
  module Legacy
    class PropertyDeclarationsCrawler
      def self.crawl_for(first_name:, last_name:, offices:)
        agent = Mechanize.new
        page = agent.get('https://www.genpro.gov.sk/prokuratura-sr/majetkove-priznania-30a3.html')
        list =
          page.form_with(name: 'uznesenia-form') do |form|
            form.field_with(name: 'meno').value = first_name
            form.field_with(name: 'priezvisko').value = last_name
          end.submit

        links = Parser.parse(list.body, offices: offices)

        links.map { |url| GenproGovSk::Legacy::PropertyDeclarationCrawler.crawl(url) }
      end

      class Parser
        def self.parse(html, offices:)
          document = Nokogiri.HTML(html)

          reported_offices =
            document.css('table.table_01 > tbody > tr').map { |node| node.css('td:nth-child(3)').text.strip }

          if reported_offices.uniq.one?
            nodes = document.css('table.table_01 > tbody > tr')
          else
            nodes =
              document.css('table.table_01 > tbody > tr').select do |node|
                node.css('td:nth-child(3)').text.strip.in?(offices)
              end
          end

          nodes.map do |node|
            url = node.css('td:nth-child(6) > a')[0]['href']

            "https://www.genpro.gov.sk/prokuratura-sr/majetkove-priznania-30a3.html#{url}"
          end
        end
      end
    end
  end
end
