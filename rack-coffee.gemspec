# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-coffee}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Lyon", "Brian Mitchell"]
  s.date = %q{2012-03-18}
  s.description = %q{Rack Middlware for compiling and serving .coffee files using coffee-script; "/javascripts/app.js" compiles and serves "/javascipts/app.coffee".}
  s.email = %q{matthew@lyonheart.us}
  s.files = [".gitignore", "Gemfile", "Gemfile.lock", "Rakefile", "Readme.mkdn", "lib/rack/coffee.rb", "rack-coffee.gemspec", "test/javascripts/cache_compile.coffee", "test/javascripts/static.js", "test/javascripts/test.coffee", "test/other_javascripts/test.coffee", "test/rack_coffee_test.rb"]
  s.homepage = %q{http://github.com/mattly/rack-coffee}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rack-coffee}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{serve up coffeescript from rack middleware}
  s.test_files = ["test/rack_coffee_test.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_runtime_dependency(%q<coffee-script>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<coffee-script>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<coffee-script>, [">= 0"])
  end
end
