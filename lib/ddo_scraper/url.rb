require 'uri'

module DDOScraper
  class URL
    def self.for_query(query)
      'https://ordnet.dk/ddo/ordbog?query=' + URI.escape(query)
    end

    def self.id_from_url(url)
      select = url[/(?:[?&])select=(.*?)(?:&|$)/, 1]
      URI.unescape(select)
    end

    def self.fixup(url)
      url.gsub(/([^\x21-\x7E]+)/, &URI.method(:escape))
    end
  end
end
