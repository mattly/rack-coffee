require 'rake/rdoctask'
require 'rake/testtask'

desc "Run all the tests"
task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = false
end

begin
  require 'rubygems'
rescue LoadError
  # Too bad.
else
  task "rack-coffee.gemspec" do
    spec = Gem::Specification.new do |s|
      s.name            = "rack-coffee"
      s.version         = "0.9.1"
      s.platform        = Gem::Platform::RUBY
      s.summary         = "serve up coffeescript from rack middleware"

      s.description     = <<-EOF
        Rack Middlware for compiling and serving .coffee files using
        coffee-script; "/javascripts/app.js" compiles and serves
        "/javascipts/app.coffee". If there is no .coffee file, can either pass to
        Rack::File in case there's a .js file (or other asset) with the requested
        url, or pass entirely.
      EOF

      s.files           = `git ls-files`.split("\n")
      s.require_path    = 'lib'
      s.has_rdoc        = false
      s.test_files      = Dir['test/*_test.rb']

      s.authors         = ['Matthew Lyon', 'Brian Mitchell']
      s.email           = 'matthew@lyonheart.us'
      s.homepage        = 'http://github.com/mattly/rack-coffee'
      s.rubyforge_project = 'rack-coffee'

      s.add_dependency 'rack'
      s.add_dependency 'coffee-script'
    end

    File.open("rack-coffee.gemspec", "w") { |f| f << spec.to_ruby }
  end

  task :gem => ["rack-coffee.gemspec"] do
    sh "gem build rack-coffee.gemspec"
  end
end
