require 'pathname'
require 'time'
require 'coffee-script'
require 'rack/file'
require 'rack/utils'

module Rack
  class Coffee
    
    attr_accessor :url, :root
    
    def initialize(app, opts={})
      @app = app
      @url = opts[:url] || '/javascripts'
      @root = Pathname.new(opts[:root] || Dir.pwd)
      @server = Rack::File.new(root)
    end
    
    def call(env)
      path = Utils.unescape(env["PATH_INFO"])
      return [403, {"Content-Type" => "text/plain"}, ["Forbidden\n"]] if path.include?('..')
      if (path.index(url) == 0) and (path =~ /\.js$/)
        coffee = root + path.sub(/\.js$/,'.coffee').sub(/^\//,'')
        if coffee.file?
          headers = {"Content-Type" => "application/javascript", "Last-Modified" => coffee.mtime.httpdate}
          [200, headers, [CoffeeScript.compile(coffee.read)]]
        else
          @server.call(env)
        end
      else
        @app.call(env)
      end
    end
    
  end
end