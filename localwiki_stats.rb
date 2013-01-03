require 'rest_client'
require 'yajl'

# LocalWiki API doc:
# http://localwiki.readthedocs.org/en/latest/api.html

# base_url is formatted as http://[url-to-wiki]/[thing-you-want]&format=json
# format=jason is the default
def wiki_get_request(base_url, resource)
  response = RestClient::Request.execute(
      :method => :get,
      :url => 'http://' + base_url + resource + '&format=json',
      :timeout => 120)
  json = StringIO.new(response.body)
  parser = Yajl::Parser.new
  parser.parse(json)
end

def get_resource(base_url, content_type, limit=0, filters="")
  resource = '/api/' + content_type + '?limit=' + limit.to_s + filters
  wiki_get_request(base_url, resource)
end

def get_wiki_name(base_url)
  wiki = get_resource(base_url, "site/1")
  wiki["name"]
end

def total_resources(base_url, content_type)
  content = get_resource(base_url, content_type)
  content["meta"]["total_count"]
end

def get_wiki_stats(base_url)
  site_thread = Thread.current
  site_thread[:output] = []
  wiki_name = get_wiki_name(base_url) << "\n"
  resource_types = ["page", "user", "file", "map"]
  resource_threads = resource_types.collect do |resource|
    Thread.new do
      label = "  #{resource.to_s}s: "
      site_thread[:output].push "#{label[0..7]} #{total_resources(base_url, resource).to_s.rjust(6)}"
    end
  end
  resource_threads.collect &:join
  site_thread[:output].sort!.reverse!
  puts wiki_name << site_thread[:output].join("\n")
end

# Reference:
# http://brigade.codeforamerica.org/pages/race-for-reuse
race_for_reuse_localwikis = [ "wikislo.org",
                              "miamiwiki.org",
                              "oaklandwiki.org",
                              "saltlakewiki.org",
                              "seattlewiki.net",
                              "burlingtonwiki.org",
                              "cuwiki.net",
                              "conway.localwiki.org",
                              "viget.org",
                              "atlanta.georgiawiki.org",
                              "olywiki.org",
                              "bmorepipeline.org",
                              "wikikc.com",
                              "toledowiki.net",
                              "arborwiki.org"
                            ]

# for each localwiki in the Race for Reuse campaign, get it's stats and print to console
site_threads = race_for_reuse_localwikis.collect do |wiki|
  Thread.new do
    begin
      sleep 0.01
      get_wiki_stats(wiki)
    rescue Errno::ETIMEDOUT => timeout
      puts "#{wiki} timed out."
    rescue => e
      puts "#{wiki} returned the error: #{e.message}."
    end
  end
end

puts "Collecting stats on #{site_threads.count} wikis ..."
site_threads.collect &:join