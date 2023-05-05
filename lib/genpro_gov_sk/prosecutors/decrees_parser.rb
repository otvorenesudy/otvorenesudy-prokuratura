module GenproGovSk
  module Prosecutors
    module DecreesParser
      def self.parse(html, url:)
        html = Nokogiri::HTML(html)
        rows = html.css('table > tbody > tr')
      
        rows.map do |row|
          columns = row.css('td')

          data = {
            url: "#{url}#{columns[0].css('a')[0][:href]}".strip,
            number: columns[0].css('a')[0].text.strip,
            file_info: row.css('td:nth(1) > text()').text.strip,
            effective_on: Date.strptime(columns[1].text.strip.squeeze(' '), '%d. %m. %Y'),
            published_on: Date.strptime(columns[2].text.strip.squeeze(' '), '%d. %m. %Y'),
            file_number: columns[3].text.strip,
            resolution: columns[4].text.strip,
            means_of_resolution: columns[5].text.strip,
          }

          _, file_type = *data[:file_info].match(/^\((\w+)/)

          next unless file_type

          data.merge(file_type: file_type.downcase)
        end.compact
      end
    end
  end
end
