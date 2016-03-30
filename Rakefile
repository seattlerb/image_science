# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.add_include_dirs("../../RubyInline/dev/lib",
                     "../../ZenTest/dev/lib")

Hoe.plugin :seattlerb
Hoe.plugin :inline
Hoe.plugin :isolate

Hoe.spec 'image_science' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  license "MIT"

  clean_globs << 'blah*png' << 'images/*_thumb.*'
end

task :debug => :isolate do
  file = ENV["F"]
  ruby "-Ilib bin/image_science_thumb 100 #{file}"
end

# vim: syntax=Ruby
