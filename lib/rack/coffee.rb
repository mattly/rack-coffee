require 'time'
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
      @cache = opts[:cache]
      @ttl = opts[:ttl] || 86400
      @join = opts[:join]
      @command = ['coffee', '-p']
      @command.push('--bare') if opts[:nowrap] || opts[:bare]
      @command = @command.join(' ')
    end
    
    def brew(coffee)
      IO.popen("#{@command} #{coffee}")
    end
    
    def call(env)
      path = Utils.unescape(env["PATH_INFO"])
      return [403, {"Content-Type" => "text/plain"}, ["Forbidden\n"]] if path.include?('..')
      return @app.call(env) unless urls.any?{|url| path.index(url) == 0} and (path =~ /\.js$/)
      coffee = F.join(root, path.sub(/\.js$/,'.coffee'))
      if @join == F.basename(coffee, '.coffee')
        headers = {"Content-Type" => "application/javascript"}
        [200, headers, brew("-j #{F.dirname(coffee)}/*")]

      elsif F.file?(coffee)

        modified_time = F.mtime(coffee)

        if env['HTTP_IF_MODIFIED_SINCE']
          cached_time = Time.parse(env['HTTP_IF_MODIFIED_SINCE'])
          if modified_time <= cached_time
            return [304, {}, ['Not modified']]
          end
        end

        headers = {"Content-Type" => "application/javascript", "Last-Modified" => F.mtime(coffee).httpdate}
        if @cache
          headers['Cache-Control'] = "max-age=#{@ttl}"
          headers['Cache-Control'] << ', public' if @cache == :public
        end
        [200, headers, brew(coffee)]
      else
        @server.call(env)
      end
    end
  end
end
