# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-coffee}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Lyon"]
  s.date = %q{2010-01-27}
  s.description = %q{Rack Middlware for compiling and serving .coffee files using coffee-script; "/scripts/app.js" compiles and serves "/scipts/app.coffee". If there is no .coffee file, passes to Rack::File in case there's a .js file (or other asset) with the requested url.
}
  s.email = %q{matt@flowerpowered.com}
  s.files = ["Readme.mkdn", "lib/rack/coffee.rb", "rack-coffee.gemspec", "test/javascripts/static.js", "test/javascripts/test.coffee", "test/other_javascripts/test.coffee", "test/rack_coffee_test.rb"]
  s.homepage = %q{http://github.com/mattly/rack-coffee}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rack-coffee}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{serve up coffeescript from rack middleware}
  s.test_files = ["test/rack_coffee_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
  end
end
