require 'time'
require 'rack/file'
require 'rack/utils'

require 'coffee_script'

module Rack
  class Coffee
    F = ::File

    attr_accessor :urls, :root, :bare

    def initialize(app, opts={})
      @app = app
      @urls = *opts[:urls] || '/javascripts'
      @root = opts[:root] || Dir.pwd
      @cache = opts[:cache]
      @ttl = opts[:ttl] || 86400
      @join = opts[:join]
      @bare = opts.fetch(:bare) { false }
    end

    def brew(coffee)
      CoffeeScript.compile coffee, {:bare => @bare }
    end

    def not_modified
      [304, {}, ['Not modified']]
    end

    def check_modified_time(env, mtime)
      ctime = env['HTTP_IF_MODIFIED_SINCE']
      ctime && mtime <= Time.parse(ctime)
    end

    def headers_for(mtime)
      headers = {
        'Content-Type' => 'application/javascript',
        'Last-Modified' => mtime.httpdate
      }
      if @cache
        headers['Cache-Control'] = "max-age=#{@ttl}"
        headers['Cache-Control'] << ", public" if @cache == :public
      end
      headers
    end

    def call(env)
      path = Utils.unescape(env["PATH_INFO"])
      return [403, {"Content-Type" => "text/plain"}, ["Forbidden\n"]] if path.include?('..')
      return @app.call(env) unless urls.any?{|url| path.index(url) == 0} and (path =~ /\.js$/)
      coffee = F.join(root, path.sub(/\.js$/,'.coffee'))
      if @join == F.basename(coffee, '.coffee')
        dir = F.dirname(coffee)
        files = Dir["#{dir}/*.coffee"]
        modified_time = files.map{|f| F.mtime(f) }.max
        brewed = files.map{|f| brew(F.read(f)) }.join("\n")
      elsif F.file?(coffee)
        modified_time = F.mtime(coffee)
        brewed = brew(F.read(coffee))
      else
        return @app.call(env)
      end
      return not_modified if check_modified_time(env, modified_time)
      [200, headers_for(modified_time), [brewed]]
    end
  end
end
