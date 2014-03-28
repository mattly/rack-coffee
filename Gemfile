source 'https://rubygems.org'

gem "rack"
gem "coffee-script"

group :test do
  gem "rake"

  # required for TravisCI: http://docs.travis-ci.com/user/languages/ruby/#Rubinius
  platforms :rbx do
    gem "racc"
    gem "rubysl", "~>2.0"
    gem "psych"
  end
end

