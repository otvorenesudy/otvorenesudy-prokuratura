class News
  def self.search_by(query)
    dennikn = DennikN.search(query)
    sme = SME.search(query)

    articles =
      dennikn.each.with_index.with_object([]) do |(article, i), array|
        array << article
        array << sme[i] if sme[i]
      end

    (articles + (sme - articles)).sort_by { |e| e[:date] || 20.years.ago }.reverse
  end

  class DennikN
    def self.search_url_for(query)
      "https://dennikn.sk/?s=#{URI.encode_www_form_component(query.gsub(/"/, ''))}"
    end

    def self.search(query)
      Parser.parse(Curl.get(search_url_for(query)).body_str)
    end

    class Parser
      def self.parse(html)
        document = Nokogiri.HTML(html)

        document.css('article > div:first-of-type, aside > div:first-of-type').map do |node|
          url =
            node.css('a').find do |e|
              !e[:href].match(%r{\/(autor|tema)\/}) && !e[:href].match(/(www.facebook.com|newsfilter)/)
            end
          author = node.css('a').find { |e| e[:href].match(%r{\/autor\/}) }

          next unless url
          next if url[:href].match(%r{\/blog\/})

          {
            title: url.text.gsub(/if \(typeof.*/, '').strip,
            url: url[:href],
            date: DateParser.parse(node.parent.css('time[datetime]')[0].text),
            author: author&.text,
            source: 'Denník N'
          }
        end.compact
      end
    end
  end

  class SME
    def self.search_url_for(query)
      "https://www.sme.sk/search?q=#{URI.encode_www_form_component(query)}&period=all&order=relevance"
    end

    def self.search(query)
      Parser.parse(Curl.get(search_url_for(query)).body_str)
    end

    class Parser
      def self.parse(html)
        document = Nokogiri.HTML(html)

        document.css('.media-body').map do |node|
          author = node.css('.media-bottom > a').remove

          node.css('.media-bottom > span').remove

          {
            title: node.css('.media-heading > a').text,
            url: node.css('.media-heading > a')[0][:href],
            author: author ? author.text.presence : nil,
            date:
              DateParser.parse(
                node.css('.media-bottom').text.gsub(/,/, '').gsub(/(\A[[:space:]]+|[[:space:]]+\z)/, '')
              ),
            source: 'SME'
          }
        end
      end
    end
  end

  class DateParser
    def self.parse(string)
      _, day, month, year = *string.match(/\A(\d+)\.\s+([[:alpha:]]+)\s+(\d{4})/)

      return nil if day.blank?

      month = month[0..2].capitalize!

      months = I18n.t('date.month_names')[1..-1]
      month = months.index { |e| e.starts_with?(month) }

      Date.parse("#{year}-#{month + 1}-#{day}")
    end
  end
end
