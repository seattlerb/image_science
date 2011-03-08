$:.push File.expand_path("../lib", __FILE__)
require "image_science"

Gem::Specification.new do |s|
  s.name = "image_science"
  s.version = ImageScience::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Ryan Davis', 'Craig Buchek']
  s.email = ['craig.buchek@asolutions.com']
  s.homepage = "http://github.com/asynchrony/#{s.name}"
  s.summary = %q{Replacement for RMagick; uses FreeImage instead of ImageMagick}
  s.description = %q{ImageScience is a clean and happy Ruby library that generates
thumbnails -- and kicks the living crap out of RMagick. Oh, and it
doesn't leak memory like a sieve. :)

For more information (on the original variant), see http://seattlerb.rubyforge.org/ImageScience.html
}

  s.rubyforge_project = "image_science"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extensions = `git ls-files -- ext/*/*.rb`.split("\n")
  s.require_paths = ["lib"]
end
