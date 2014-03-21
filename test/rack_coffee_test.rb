require 'test/unit'
begin
  require 'rack/mock'
  require 'rack/lint'
rescue LoadError
  require 'rubygems'
  retry
end

require File.dirname(__FILE__) + "/../lib/rack/coffee"

class DummyApp
  def call(env)
    [201, {"Content-Type" => "text/plain"}, ["Default Response"]]
  end
end

class RackCoffeeTest < Test::Unit::TestCase

  attr_reader :compiled_body_regex

  def setup
    @root = File.expand_path(File.dirname(__FILE__))
    @options = {:root => @root}
    @compiled_body_regex = /function.*alert\(\"coffee\"\)\;.*this/m
  end

  def request(options={})
    options = @options.merge(options)
    Rack::MockRequest.new(Rack::Lint.new(Rack::Coffee.new(DummyApp.new, options)))
  end

  def test_serves_coffeescripts
    result = request.get("/javascripts/test.js")
    assert_equal 200, result.status
    assert_match compiled_body_regex, result.body
    assert_equal File.mtime("#{@root}/javascripts/test.coffee").httpdate, result["Last-Modified"]
    assert_equal result.body.size.to_s, result["Content-Length"]
  end

  def test_calls_app_on_coffee_miss
    result = request.get("/javascripts/static.js")
    assert_equal 201, result.status
    assert_equal "Default Response", result.body
  end

  def test_calls_app_on_path_miss
    result = request.get("/hello")
    assert_equal 201, result.status
    assert_equal "Default Response", result.body
  end

  def test_not_modified_response
    modified_time = (File.mtime("#{@root}/javascripts/test.coffee") + 1).httpdate
    result = request.get("/javascripts/test.js", 'HTTP_IF_MODIFIED_SINCE' => modified_time )
    assert_equal 304, result.status
    assert_equal 'Not modified', result.body
  end
  
  def test_does_not_allow_directory_traversal
    result = request.get("/javascripts/../README.js")
    assert_equal 403, result.status
  end
  
  def test_does_not_allow_directory_travesal_with_encoded_periods
    result = request.get("/javascripts/%2E%2E/README.js")
    assert_equal 403, result.status
  end
  
  def test_serves_coffeescripts_with_alternate_options
    result = request({:root => File.expand_path(File.dirname(__FILE__)), :urls => "/other_javascripts"}).get("/other_javascripts/test.js")
    assert_equal 200, result.status
    assert_match /alert\(\"other coffee\"\)\;/, result.body
  end

  def test_cache_control_defaults
    result = request({:cache_control => true}).get("/javascripts/test.js")
    cache = result.headers["Cache-Control"]
    assert_not_nil cache
    assert_equal "max-age=86400", cache
  end

  def test_cache_control_with_options
    result = request({:cache_control => %w(300 public)}).get("/javascripts/test.js")
    cache = result.headers["Cache-Control"]
    assert_not_nil cache
    assert_match /max-age=300/, cache
    assert_match /, public/, cache
  end

  def test_cache_control_option_parsing
    [ [300, "max-age=300"], ['300', "max-age=300"],
      [:public, "max-age=86400, public"], ['public', "max-age=86400, public"],
      [[300, :public], "max-age=300, public"],
      [%w(300 public), "max-age=300, public"]
    ].each do |given, expected|
      middleware = Rack::Coffee.new(DummyApp, {:cache_control => given})
      assert_equal expected, middleware.cache_control
    end
  end

  def test_bare_option
    result = request({:bare => true}).get("/javascripts/test.js")
    assert_equal "alert(\"coffee\");", result.body.strip
  end

  def test_join_option_with_join
    result = request({:join => 'index'}).get("/javascripts/index.js")
    assert_equal 200, result.status
  end

  def test_join_option_with_file
    result = request({:join => 'index'}).get("/javascripts/test.js")
    assert_equal 200, result.status
    assert_match compiled_body_regex, result.body.strip
  end

  def test_cache_compile_option
    Dir.mktmpdir do |root|
      FileUtils.mkdir "#{root}/javascripts"
      app = Rack::Coffee.new(DummyApp, {:root => root, :cache_compile => true})
      get = lambda{|path| Rack::MockRequest.new(Rack::Lint.new(app)).get(path) }
      dir = app.cache_compile_dir
      path = File.join(root, 'javascripts/cache_compile.coffee')
      File.open(path,'w') {|f| f.write 'alert("version one")' }
      oldtime = Time.local(2010, 11, 23, 19, 0)
      File.utime(oldtime, oldtime, path)
      # 1: is it creating the cached compiled file?
      result = get.call('/javascripts/cache_compile.js')
      cache_file = File.join(dir, "#{oldtime.to_i}_cache_compile.coffee")
      assert File.exist?(cache_file)
      assert_equal 200, result.status
      # 2: will it presumably re-use it if it hasn't changed?
      # yes, I'm using sleep in my tests. Deal with it.
      cache_mtime = File.mtime(cache_file)
      sleep 1
      get.call('/javascripts/cache_compile.js')
      assert_equal File.mtime(cache_file), cache_mtime
      # 3: will it overwrite it if the underlying contents change?
      File.open(path, 'w') {|f| f.write 'alert("version two")' }
      result = get.call('/javascripts/cache_compile.js')
      assert_equal 200, result.status
      mtime = Time.parse(result.headers['Last-Modified'])
      assert_not_equal mtime, oldtime
      assert File.exist?(File.join(dir, "#{mtime.to_i}_cache_compile.coffee"))
    end
  end

  def test_does_not_break_if_cache_compile_dir_is_deleted
    Dir.mktmpdir do |root|
      FileUtils.mkdir "#{root}/javascripts"
      app = Rack::Coffee.new(DummyApp, {:root => root, :cache_compile => true})
      get = lambda{|path| Rack::MockRequest.new(Rack::Lint.new(app)).get(path) }
      path = File.join(root, 'javascripts/cache_compile.coffee')
      File.open(path,'w') {|f| f.write 'alert("version one")' }
      dir = app.cache_compile_dir
      get.call('/javascripts/cache_compile.js')
      dir.rmtree
      assert_nothing_raised Errno::ENOENT do
        get.call('/javascripts/cache_compile.js')
      end
      assert dir.exist?
    end
  end
end
