require 'test/unit'
require 'rack/mock'
require 'rack/lint'
require 'ruby-debug'

require File.dirname(__FILE__) + "/../lib/rack/coffee"

class DummyApp
  def call(env)  
    [200, {"Content-Type" => "text/plain"}, ["Hello World"]]
  end
end

class RackCoffeeTest < Test::Unit::TestCase
  
  def setup
    @root = File.expand_path(File.dirname(__FILE__))
    @options = {:root => @root}
  end
  
  def request(options={})
    options = @options.merge(options)
    Rack::MockRequest.new(Rack::Lint.new(Rack::Coffee.new(DummyApp.new, options)))
  end
  
  def test_serves_coffeescripts
    result = request.get("/javascripts/test.js")
    assert_equal 200, result.status
    assert_match /alert\(\"coffee\"\)\;/, result.body
    assert_equal File.mtime("#{@root}/javascripts/test.coffee").httpdate, result["Last-Modified"]
  end
  
  def test_serves_javascripts
    result = request.get("/javascripts/static.js")
    assert_equal 200, result.status
    assert_equal %|alert("static");|, result.body
  end
  
  def test_calls_app_on_path_miss
    result = request.get("/hello")
    assert_equal 200, result.status
    assert_equal "Hello World", result.body
  end
  
  def test_does_not_allow_directory_traversal
    result = request.get("/../README")
    assert_equal 403, result.status
  end
  
  def test_does_not_allow_directory_travesal_with_encoded_periods
    result = request.get("/%2E%2E/README")
    assert_equal 403, result.status
  end
  
  def test_serves_coffeescripts_with_alternate_options
    result = request({:root => File.expand_path(File.dirname(__FILE__)), :url => "/other_javascripts"}).get("/other_javascripts/test.js")
    assert_equal 200, result.status
    assert_match /alert\(\"other coffee\"\)\;/, result.body
  end
  
end