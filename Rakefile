# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/image_science.rb'

Hoe.new('image_science', ImageScience::VERSION) do |p|
  p.rubyforge_name = 'seattlerb'
  p.description = p.paragraphs_of('README.txt', 2..3).join(" ")
  p.summary = p.description[/^[^.]+\./]
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1].first.strip
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << 'RubyInline'
  p.clean_globs << 'blah*png'
end

# vim: syntax=Ruby
