require 'local_wiki'

# LocalWiki API doc:
# http://localwiki.readthedocs.org/en/latest/api.html

localwikis = [ "wikislo.org",
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

def get_wiki_stats(base_url)
  wiki = LocalWiki.new base_url
  site_thread = Thread.current
  site_thread[:output] = []
  wiki_name = wiki.site_name << "\n"
  resource_types = ["page", "user", "file", "map"]
  resource_threads = resource_types.collect do |resource|
    Thread.new do
      label = "  #{resource.to_s}s: "
      site_thread[:output].push "#{label[0..7]} #{wiki.total_resources(resource).to_s.rjust(6)}"
    end
  end
  resource_threads.collect &:join
  site_thread[:output].sort!.reverse!
  puts wiki_name << site_thread[:output].join("\n")
end

# for each localwiki, get it's stats and print to console
site_threads = localwikis.collect do |wiki|
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
