require 'rack/file'
require 'rack/utils'

class Rack::Coffee

  attr_accessor :urls, :root, :cache

  DEFAULTS = {:static => true}

  def initialize(pass, opts = {})
    opts = DEFAULTS.merge(opts)
    @pass = pass
    @urls = *opts[:urls] || '/scripts'
    @root = opts[:root] || Dir.pwd
    @server = opts[:static] ? Rack::File.new(root) : pass
    @cache = opts[:cache]
    @ttl = opts[:ttl] || 86400
  end

  def brew(coffee)
    IO.popen(['coffee', '-p', coffee])
  end

  def call(env)
    path = Rack::Utils.unescape(env["PATH_INFO"])
    return [403, {"Content-Type" => "text/plain"}, ["Forbidden\n"]] if path.include?('..')
    return @pass.call(env) unless urls.any? {|url| path.index(url) == 0} && path =~ /\.js$/
    coffee = File.join(root, path.sub(/\.js$/, '.coffee'))
    if File.file?(coffee)
      headers = {
        'Content-Type' => 'application/javascript',
        'Last-Modified' => File.mtime(coffee).httpdate}
      if cache
        headers['Cache-Control'] = "max-age=#{@ttl}"
        headers['Cache-Control'] << ', public' if cache == :public
      end
      [200, headers, brew(coffee)]
    else
      @server.call(env)
    end
  end

end
