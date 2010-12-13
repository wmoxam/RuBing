require 'rubygems'

# Usage:
# RuBing::Search::app_id = 'xxxxxxxxxx'
# RuBing::Search::base_site = 'learnhub.com'
#
# response = RuBing::Search.get('Ruby')
# puts response.total_results
# response.results.each do |result|
#  puts "#{result.title} #{result.url}"
# end
#
# Author::    Wesley Moxam (wesley.moxam@savvica.com)
# Copyright:: Copyright (c) 2009 Savvica Inc
# Licence::   Distributes under the same terms as Ruby
#
module RuBing
  class Search
    require 'net/http'
    require 'uri'

    DEFAULT_COUNT = 20

    @@base_url = 'http://api.search.live.net/json.aspx?'
    @@base_site = nil
    @@app_id = nil

    def self.base_site=(bs)
      @@base_site = bs
    end

    def self.base_site
      @@base_site
    end

    def self.app_id=(ai)
      @@app_id = ai
    end

    def self.app_id
      @@app_id
    end

    def self.get(query, options = {})
      Response.new(get_json(query, options), options[:web_count] || DEFAULT_COUNT)
    end

    private
    def self.get_json(query, options)
      Net::HTTP.get(URI.parse(@@base_url + get_options(query, options)))
    end

    def self.get_options(query, options)
      normalized_query = base_site.nil? ? query : "site:#{base_site} #{query}"
      # TODO: will need seperate defaults when I fully support more than just web sources
      config = { :app_id => app_id,
                 :disable_host_collapsing => true,
                 :sources => 'web',
                 :web_count => DEFAULT_COUNT,
                 :web_offset => 0,
                 :page => 1,
                 :query => normalized_query
               }.update(options)
      config[:page] = 1 if config[:page].to_i < 1
      config[:web_offset] = config[:web_count] * (config[:page].to_i - 1)

      raise 'You must set app_id in order to query live.com' if config[:app_id].nil?
      dotted_params = %w{ ad image news mobile_web phonebook web video }
      query_items = []
      config.each_pair do |key, value|
        if(/^(#{dotted_params.join('|')})/.match(key.to_s))
          # most params are camelcase, except if they are Source specific. ex: Web.Count
          first_key = $~[1]
          second_key = key.to_s.sub("#{first_key}_", '')
          query_items << "#{camelize(first_key)}.#{camelize(second_key)}=#{URI.encode(value.to_s)}"
        else
          query_items << "#{camelize(key.to_s)}=#{URI.encode(value.to_s)}"
        end
      end
      query_items.join("&")
    end

    def self.camelize(str)
      words = str.split(/_/)
      words.inject("") {|camelized, word| camelized + word.capitalize }
    end
  end

  class Response
    require 'json'

    def initialize(json, count)
      @json = json
      @count = count
    end

    def results
      @results ||= get_results
    end

    def total_results
      @total_results ||= get_total_results
    end

    def total_pages
      total_results / @count
    end

    def current_page
      (offset / @count) + 1
    end

    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    def next_page
      current_page < total_pages ? (current_page + 1) : nil
    end

    def offset
      @offset ||= get_offset
    end

    private
    def get_results
      parsed_json["SearchResponse"]["Web"]["Results"].collect {|r| Result.new(r) } rescue []
    end

    def get_total_results
      parsed_json["SearchResponse"]["Web"]["Total"] rescue 0
    end

    def get_offset
      parsed_json["SearchResponse"]["Web"]["Offset"] rescue 0
    end

    def parsed_json
      @parsed_json ||= JSON.parse(@json)
    end
  end

  class Result
    REQUIRED_ATTRIBUTES = %w{title description url}

    def initialize(result_hash)
      @data = result_hash
      result_hash.each_pair do |key, value|
        next if key == "SearchTags" || key == "DeepLinks" # not sure why this is returned. I don't want it  :p
        begin
          instance_eval(<<-EOS, __FILE__, __LINE__)
            def #{Result.rubyize(key)}
              #{value.dump}
            end
          EOS
        rescue Exception => e
          puts "Bad Key: '#{key}' #{e.message}"
          puts result_hash.inspect
        end
      end
    end

    # So in some unknown situations Bing does not return some attributes!
    def method_missing(method_name, *args, &block)
      return "" if REQUIRED_ATTRIBUTES.include?(method_name.to_s)
      raise NoMethodError
    end

    def data
      @data
    end

    private
    def self.rubyize(str)
      letters = str.split(/([A-Z])/).reject {|l| l == ""}
      letters.inject("") {|rubyized, letter| (letter == letter.downcase) ? rubyized + letter + '_' : rubyized + letter.downcase }.chop
    end
  end
end
