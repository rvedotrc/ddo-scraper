module DDOScraper
  class Page
    def initialize(page)
      @page = page
    end

    def id
      href = doc.css('.opslagsordBox .searchResultBox a.searchMatch').first[:href]
      href = DDOScraper::URL.fixup(href)
      DDOScraper::URL.id_from_url(href)
    end

    def match
      # the word itself, possibly with "1", "2" etc appended
      doc.css('.artikel .definitionBoxTop .match').text
    end

    def part_of_speech
      # "verbum"; "substantiv, fælleskøn"
      doc.css('.artikel .definitionBoxTop .tekstmedium').text
    end

    def bøjning
      # can include dividers, explanatory text, etc
      doc.css('#id-boj .tekstmedium').text
    end

    def udtale
      doc.css('#id-udt .lydskrift').map do |node|
        {
          text: node.text[/\[(.*)\]/, 1]
        }
      end
    end

    def search_result_urls
      urls = doc.css('.opslagsordBox .searchResultBox a').map { |e| e[:href] }
      urls.map(&DDOScraper::URL.method(:fixup))
    end

    private

    attr_reader :page

    def doc
      require 'nokogiri'
      @doc ||= Nokogiri::HTML.parse(page[:body])
    end
  end
end
