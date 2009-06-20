# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.spec 'image_science' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  extra_deps  << 'RubyInline'
  clean_globs << 'blah*png' << 'images/*_thumb.*'
  clean_globs << File.expand_path("~/.ruby_inline")
end

task :test => :clean

# vim: syntax=Ruby
