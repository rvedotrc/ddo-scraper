module DDOScraper
  class QueryResults
    def initialize(query)
      @query = query
    end

    def pages
      url = DDOScraper::URL.for_query(@query)
      p url

      first_page = DDOScraper::Mirror.new.mirror_page(url)

      by_id = {
        first_page.id => first_page,
      }

      first_page.search_result_urls.each do |search_result_url|
        p search_result_url
        search_result_id = DDOScraper::URL.id_from_url(search_result_url)
        next if by_id.key?(search_result_id)

        by_id[search_result_id] = DDOScraper::Mirror.new.mirror_page(search_result_url)
      end

      by_id
    end
  end
end
