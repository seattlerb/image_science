# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/image_science.rb'

Hoe.new('image_science', ImageScience::VERSION) do |image_science|
  image_science.developer('Ryan Davis', 'ryand-ruby@zenspider.com')

  image_science.extra_deps << 'RubyInline'
  image_science.clean_globs << 'blah*png' << 'images/*_thumb.*'
end

# vim: syntax=Ruby
