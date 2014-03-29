# rack-coffee

Simple rack middleware for serving up [CoffeeScript][coffee] files as compiled
javascript.

[![Build Status](https://travis-ci.org/mattly/rack-coffee.png?branch=master)](https://travis-ci.org/mattly/rack-coffee)

## Usage

The options behave similarly to Rack::Static:

    require 'rack/coffee'
    use Rack::Coffee,
        :root => '/path/to/directory/above/url',
        :urls => '/javascipts'

For rails, presuming you've required 'rack/coffee' somehow, stick this in the
Rails initializer config block:

    config.middleware.use Rack::Coffee, :root => "#{RAILS_ROOT}/public"

Note however that by default this will not play nicely with
`javascript_include_tag`'s `:cache` option, you would need to compile your
.coffee files before deploying. Alternately, use the rails asset pipeline.

## Options

* `:root`: the directory above `urls`. Defaults to `Dir.pwd`.
* `:urls`: the directories in which to look for coffeescripts. May specify
  a string or an array of strings. Defaults to `/javascripts`.
* `:cache-compile`: When truthy, will create and look for tempfiles with the
  timestamp of the desired coffee file, and use those. Meant to speed up
  development of projects with lots of coffee files.
* `:cache-control`: Sets a `Cache-Control` header if present. Defaults to false.
  Values are interpreted like so:
    - `true`: max-age=86400
    - `3600`: max-age=3600
    - `:public` or `'public'`: max-age=86400, public
    - `[3600, :public]` or `%w(3600 public)`: max-age=3600, public
    - `false` or `nil`: disables cache header
* `:bare`: When `true`, disables the top-level function wrapper that
  CoffeeScript uses by default.
* `:join`: Set to a string, f.e. "index" to concat all the .coffee files before
  compiling

## Bugs?

* Let me know here: [Issue Tracking][issues]

## Requirements

* [CoffeeScript Gem][coffee-gem] and therefore [execjs][]
* [Rack][rack]

## History

* March 28, 2014:
    Release 1.0.3. Requests now return a Content-Length header, and are
    therefore valid without needing something like Rack::ContentLength. Thanks
    to [Naksu](https://github.com/naksu) for the fix.

* August 14, 2013:
    Release 1.0.2. Fixes a bug whereby bad things happen when the cache-compile
    directory is deleted. Thanks to [Tomas Rojas](https://github.com/tmsrjs) for
    the fix.

* July 13, 2013:
    Release 1.01. Add "Licence" field to gemspec. See [this][gemspec-license]
    for more info. As someone who recently had to do a license audit,
    I appreciate having this available.

[gemspec-license]: http://www.benjaminfleischer.com/2013/07/12/make-the-world-a-better-place-put-a-license-in-your-gemspec/

* March 18, 2012:
    This release is **NOT BACKWARDS COMPATIBLE** with 0.9.x.
    * added a `:cache_compile` option. If truthy, will cache the compiled coffee
      to a tempfile timestamped with the modification time of the original.
    * **BACKWARDS INCOMPATIBILITY** chance the `:cache` and `:ttl` options into
      `:cache_control`. See documentation above for how the arguments work.
    * A fair bit of refactoring to make the main call method easier to follow.
    * **BACKWARDS INCOMPATIBILITY** remove `:static` option. If you want to
      serve stock javascript files from the same directory as your coffeescript
      files, stick a Rack::File in your middleware stack after Rack::Coffee.
    * **BACKWARDS INCOMPATIBILITY** remove `:nowrap` option in favor of `:bare`
    * Use `execjs` gem instead of coffee-script command. Thanks to [jewel][] for
      kicking this off, even if I didn't use their code.

* May 5, 2011: release 0.9.1
    * Fix a bug in the 'join' option to reflect how command-line -p actually
      works

* May 3, 2011: release 0.9
    * Make '304 NOT MODIFIED' return a correct response body on Ruby 1.9
      [Aanand Prasad][aanand]
    * Added 'join' option for concating your js

* January 21, 2011: release 0.3.3
    Two changes by [Jonathan Baudanza][jbaudanza]:
    * changed --nowrap to --bare, per a recent change to coffee-script. You may
      use :nowrap or :bare to indicate you want this
    * return 304 NOT MODIFIED for caching purposes

* March 21, 2010: release 0.3.2
    * added :nowrap option to config, allowing the disabling of the top-level
      function wrapper.

* March 6, 2010: release 0.3.1
    * options now take :cache and :ttl options for setting cache headers, should
      you decide to actually serve up hot coffeescripts outside of your
      development environment. Via Brian Mitchell. 

* March 6, 2010: release 0.3 REQUIRES COFFEE-SCRIPT 0.5 OR HIGHER
    * CoffeeScript is now written in coffeescript. The included compiler is now
      based on node.js instead of being hosted in a ruby gem, so we're shelling
      out to the command-line interpreter. Thanks to [Brian Mitchell][binary42]
      for doing most of the dirty work, at least as far as ruby 1.9 is
      concerned.

* January 27, 2010: release 0.2 BACKWARDS INCOMPATIBLE
    * replace :url parameter in favor of :urls, now it behaves similarly to
      Rack::Static (Brian Mitchell)
    * add :static parameter, which when false will disable automatic asset
      serving of url misses via Rack::File, instead passing through to the app.
    * improve documentation for Rails
    * remove dependency on Pathname, oh if only it were stdlib instead of extlib

* January 26, 2010: First public release 0.1.

## Copyright

Copyright (C) 2010 Matthew Lyon <matthew@lyonheart.us>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[coffee]: http://jashkenas.github.com/coffee-script/
[coffee-gem]: https://github.com/josh/ruby-coffee-script
[execjs]: https://github.com/sstephenson/execjs
[issues]: http://github.com/mattly/rack-coffee/issues
[rack]: http://rack.rubyforge.org/
[binary42]: http://github.com/binary42
[jbaudanza]: https://github.com/jbaudanza
[aanand]: https://github.com/aanand
[jewel]: https://github.com/jewel
