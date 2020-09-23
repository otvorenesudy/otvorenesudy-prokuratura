class News
  def self.search_by(query)
    dennikn = DennikN.search(query)
    sme = SME.search(query)

    articles =
      dennikn.each.with_index.with_object([]) do |(article, i), array|
        array << article
        array << sme[i] if sme[i]
      end

    articles + (sme - articles)
  end

  class DennikN
    def self.search_url_for(query)
      "https://dennikn.sk/?s=#{URI.encode_www_form_component(query)}"
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

          {
            title: url.text.gsub(/if \(typeof.*/, '').strip,
            url: url[:href],
            date: node.parent.css('time[datetime]')[0].text,
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
            date: node.css('.media-bottom').text.gsub(/,/, '').gsub(/(\A[[:space:]]+|[[:space:]]+\z)/, ''),
            source: 'SME'
          }
        end
      end
    end
  end
end
