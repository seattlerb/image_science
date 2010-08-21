# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.add_include_dirs("../../RubyInline/dev/lib",
                     "../../ZenTest/dev/lib")

Hoe.plugin :seattlerb
Hoe.plugin :inline

Hoe.spec 'image_science' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  self.rubyforge_name = 'seattlerb'

  clean_globs << 'blah*png' << 'images/*_thumb.*'
end

# vim: syntax=Ruby
