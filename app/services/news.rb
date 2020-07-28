class News
  def self.search_by(query)
    dennikn = DennikN.search(query)
    sme = SME.search(query)

    dennikn[0..4].each.with_index.with_object([]) do |(article, i), array|
      array << article
      array << sme.delete_at(i) if sme[i]
    end
  end

  class DennikN
    def self.search_url_for(query)
      URI.encode("https://dennikn.sk/?s=#{query}")
    end

    def self.search(query)
      Parser.parse(Curl.get(search_url_for(query)).body_str)
    end

    class Parser
      def self.parse(html)
        document = Nokogiri.HTML(html)

        document.css('.a_art_b').map do |node|
          {
            title: node.css('a > h3.a_art_t').text.gsub(/if \(typeof.*\z/, ''),
            url: node.css('a > h3.a_art_t')[0].parent[:href],
            date: node.css('.e_terms_posted')[0].text,
            author: node.css('.e_terms_author')[0].text.presence,
            source: 'Denník N'
          }
        end
      end
    end
  end

  class SME
    def self.search_url_for(query)
      URI.encode("https://www.sme.sk/search?q=#{query}&period=90&order=relevance")
    end

    def self.search(query)
      Parser.parse(Curl.get(search_url_for(query)).body_str)
    end

    class Parser
      def self.parse(html)
        document = Nokogiri.HTML(html)

        document.css('.media-body').map do |node|
          author = node.css('.media-bottom > a').remove

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
