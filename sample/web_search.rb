#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), "..", "lib", "rubing")

RuBing::Search::app_id = 'YOURAPPID'

if ARGV[0].nil?
  puts "Usage: sample/web_search.rb TEXT"
  exit(0)
end

puts "Searching for #{ARGV[0]}"

RESULTS_PER_PAGE = 10

1.upto(4) do |page|
  puts "Page: #{page}"
  offset = RESULTS_PER_PAGE * (page - 1)
  response = RuBing::Search.get(ARGV[0], :web_count => RESULTS_PER_PAGE, :page => page, :market => 'en-ca')
  response.results.each_with_index do |result, i|
    puts "##{offset + i + 1} - #{result.title} | #{result.url}"
  end
end

