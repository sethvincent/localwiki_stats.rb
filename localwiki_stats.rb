require 'rest_client'
require 'yajl'
require 'pp'

# LocalWiki API doc:
# http://localwiki.readthedocs.org/en/latest/api.html

# base_url is formatted as http://[url-to-wiki]/[thing-you-want]&format=json
# format=jason is the default
def wiki_get_request(base_url, resource)
    response = RestClient.get 'http://' + base_url + resource + '&format=json'
    json = StringIO.new(response.body)
    parser = Yajl::Parser.new
    parser.parse(json)
end

def get_resource(content_type, limit=0, filters="")
  resource = '/api/' + content_type + '?limit=' + limit.to_s + filters
  content = wiki_get_request(@base_url, resource)
end

def get_wiki_name(base_url)
  wiki = get_resource("site/1")
  wiki["name"]
end

def total_resources(content_type)
  content = get_resource(content_type)
  content["meta"]["total_count"]
end

def get_wiki_stats(base_url)
  @base_url = base_url
  pp get_wiki_name(base_url)
  resource_types = ["page", "user", "file", "map"]
  resource_types.each do |resource|
    pp resource.to_s + "s: " + total_resources(resource).to_s
  end
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
race_for_reuse_localwikis.each do |wiki|
  begin
    get_wiki_stats(wiki)
  rescue Errno::ETIMEDOUT => timeout
    puts "\"#{wiki}\" timed out."
  rescue => e
    puts "\"#{wiki}\" returned the error: #{e.message}."
  end
end
