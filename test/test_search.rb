require 'test/unit'
require File.join(File.dirname(__FILE__), "..", "lib", "rubing")

class SearchTest < Test::Unit::TestCase
  RuBing::Search::app_id = 'YOURAPPID'
  RuBing::Search::base_site = 'learnhub.com'

  def test_response
    response = RuBing::Search.get('Ruby')
    assert_not_nil response, "Should return a result"
    assert response.total_results > 0, "Total results should be greater than zero"
  end

  def test_get_results
    response = RuBing::Search.get('Ruby', {:web_count => 20})
    assert_equal 20, response.results.length
  end

  def test_result_structure
    response = RuBing::Search.get('Ruby')
    RuBing::Result::REQUIRED_ATTRIBUTES.each do |attrib|
      assert response.results.first.respond_to?(attrib.to_sym), "Missing required attribute #{attrib}.}"
    end
  end
end
