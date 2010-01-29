require 'time'
require 'coffee-script'
require 'rack/file'
require 'rack/utils'

module Rack
  class Coffee
    F = ::File
    
    attr_accessor :urls, :root
    DEFAULTS = {:static => true}
    
    def initialize(app, opts={})
      opts = DEFAULTS.merge(opts)
      @app = app
      @urls = *opts[:urls] || '/javascripts'
      @root = opts[:root] || Dir.pwd
      @server = opts[:static] ? Rack::File.new(root) : app
    end
    
    def call(env)
      path = Utils.unescape(env["PATH_INFO"])
      return [403, {"Content-Type" => "text/plain"}, ["Forbidden\n"]] if path.include?('..')
      return @app.call(env) unless urls.any?{|url| path.index(url) == 0} and (path =~ /\.js$/)
      coffee = F.join(root, path.sub(/\.js$/,'.coffee'))
      if F.file?(coffee)
        headers = {"Content-Type" => "application/javascript", "Last-Modified" => F.mtime(coffee).httpdate}
        [200, headers, [CoffeeScript.compile(F.read(coffee))]]
      else
        @server.call(env)
      end
    end
  end
end
