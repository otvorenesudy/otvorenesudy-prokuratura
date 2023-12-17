module GenproGovSk
  module Decrees
    module Parser
      def self.parse(html, url:)
        html = Nokogiri.HTML(html)
        rows = html.css('.tx-tempest-applications .govuk-table tbody tr')

        rows
          .map do |row|
            columns = row.css('td')

            link = columns[0].css('a')[0]

            next unless link

            data = {
              url: "#{url}#{link[:href]}",
              number: columns[0].css('a')[0].text.strip,
              effective_on: Date.strptime(columns[1].text.strip.squeeze(' '), '%d. %m. %Y'),
              published_on: Date.strptime(columns[2].text.strip.squeeze(' '), '%d. %m. %Y'),
              file_number: columns[3].text.strip,
              resolution: columns[4].text.strip,
              means_of_resolution: columns[5].text.strip
            }

            _, file_type = columns[0].css('a')[0][:href].match(/\.([^.]+)$/).to_a

            data.merge(file_type: file_type.downcase)
          end
          .compact
      end
    end
  end
end
