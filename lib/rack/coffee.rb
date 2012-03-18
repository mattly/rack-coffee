require 'time'
require 'pathname'
require 'rack/file'
require 'rack/utils'

require 'coffee_script'

module Rack
  class Coffee
    F = ::File

    attr_accessor :app, :urls, :root,
      :compile_without_closure, :concat_to_file

    def initialize(app, opts={})
      @app = app
      @urls = [opts.fetch(:urls, '/javascripts')].flatten
      @root = Pathname.new(opts.fetch(:root) { Dir.pwd })
      @cache = opts.fetch(:cache, false)
      @ttl = opts.fetch(:ttl, 86400)
      @concat_to_file = opts.fetch(:join, false)
      @concat_to_file += '.coffee' if @concat_to_file
      @compile_without_closure = opts.fetch(:bare, false)
    end

    def brew(coffee)
      CoffeeScript.compile coffee, {:bare => compile_without_closure }
    end

    def not_modified
      [304, {}, ["Not modified"]]
    end

    def forbidden
      [403, {'Content-Type' => 'text/plain'}, ["Forbidden\n"]]
    end

    def check_modified_since(rack_env, last_modified)
      cache_time = rack_env['HTTP_IF_MODIFIED_SINCE']
      cache_time && last_modified <= Time.parse(cache_time)
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

    def own_path?(path)
      path =~ /\.js$/ && urls.any? {|url| path.index(url) == 0}
    end

    def call(env)
      path = Utils.unescape(env["PATH_INFO"])
      return app.call(env) unless own_path?(path)
      return forbidden if path.include?('..')
      desired_file = root + path.sub(/\.js$/, '.coffee').sub(%r{^/},'')
      if concat_to_file == String(desired_file.basename)
        source_files = Pathname.glob("#{desired_file.dirname}/*.coffee")
      elsif desired_file.file?
        source_files = [desired_file]
      else
        return app.call(env)
      end
      last_modified = source_files.map {|file| file.mtime }.max
      return not_modified if check_modified_since(env, last_modified)
      brewed = source_files.map{|file| brew(file.read) }.join("\n")
      [200, headers_for(last_modified), [brewed]]
    end
  end
end
