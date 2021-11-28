require 'digest/sha1'
require 'faraday'
require 'fileutils'
require 'json'
require 'tempfile'

module DDOScraper
  class Mirror
    def initialize
      @mirror_dir = "./var/mirror"
      FileUtils.mkdir_p @mirror_dir
    end

    def mirror_word(word)
      url = DDOScraper::URL.for_query(word)
      mirror_page(url)
    end

    def mirror_page(url)
      key = Digest::SHA1.hexdigest(url)
      file = "#{@mirror_dir}/#{key}"

      page = begin
               read_file(file)
             rescue Errno::ENOENT
               do_mirror(url, file)
               read_file(file)
             end

      DDOScraper::Page.new(page)
    end

    private

    def do_mirror(url, file)
      json_file = file + ".json"
      html_file = file + ".html"
      t = Time.now

      r = Faraday.get(url)
      puts "GET #{url} => #{r.status}"

      payload = {
        url: url,
        fetched_at: t.to_f,
        status: r.status,
        headers: r.headers.to_h,
      }

      body = r.body.force_encoding('utf-8')

      raise payload.inspect if r.status != 200

      Tempfile.open('do_mirror', @mirror_dir) do |json_fh|
        Tempfile.open('do_mirror', @mirror_dir) do |html_fh|
          json_fh.puts JSON.pretty_generate(payload)
          json_fh.flush
          json_fh.chmod 0o644
          html_fh.print body
          html_fh.flush
          html_fh.chmod 0o644
          File.rename json_fh.path, json_file
          File.rename html_fh.path, html_file
        end
      end
    end

    def read_file(file)
      body = File.read(file + ".html")
      meta = JSON.parse(File.read(file + ".json"), symbolize_names: true)
      meta.merge(body: body)
    end
  end
end
