require 'rest_client'
require 'yajl'
require 'pp'

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

localwiki_installs_without_api = ["wikislo.org"]
race_for_reuse_localwikis = [ "miamiwiki.org", 
                              "oaklandwiki.org", 
                              "saltlakewiki.org", 
                              "seattlewiki.net", 
                              "burlingtonwiki.org", 
                              "cuwiki.net", 
                              "conway.localwiki.org", 
                              "198.74.52.32", 
                              "arborwiki.org", 
                              "wiki.openatlanta.net"
                            ]


race_for_reuse_localwikis.each do |wiki|
  get_wiki_stats(wiki)
end
