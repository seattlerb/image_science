#!/usr/local/bin/ruby -w

require 'benchmark'
require 'rubygems'
require 'image_science'

file = "blah_big.png"

if RUBY_PLATFORM =~ /darwin/ then
  # how fucking cool is this???
  puts "taking screenshot for thumbnailing benchmarks"
  system "screencapture -SC #{file}"
else
  abort "You need to plonk down #{file} or buy a mac"
end unless test ?f, "#{file}"

max = (ARGV.shift || 100).to_i

puts "# of iterations = #{max}"
Benchmark::bm(20) do |x|
  x.report("null_time") {
    for i in 0..max do
      # do nothing
    end
  }

  x.report("cropped") {
    for i in 0..max do
      ImageScience.with_image(file) do |img|
        img.cropped_thumbnail(100) do |thumb|
          thumb.save("blah_cropped.png")
        end
      end
    end
  }

  x.report("proportional") {
    for i in 0..max do
      ImageScience.with_image(file) do |img|
        img.thumbnail(100) do |thumb|
          thumb.save("blah_thumb.png")
        end
      end
    end
  }

  x.report("resize") {
    for i in 0..max do
      ImageScience.with_image(file) do |img|
        img.resize(200, 200) do |resize|
          resize.save("blah_resize.png")
        end
      end
    end
  }
end

# File.unlink(*Dir["blah*png"])
