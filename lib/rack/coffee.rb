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
        modified_time = Dir["#{dir}/*.coffee"].map{|f| F.mtime(f) }.max
        coffee = "#{dir}/"
      elsif F.file?(coffee)
        modified_time = F.mtime(coffee)
      end
      if modified_time
        return not_modified if check_modified_time(env, modified_time)
        [200, headers_for(modified_time), brew(coffee)]
      else
        @server.call(env)
      end
    end
  end
end
