require 'bundler'
Bundler::GemHelper.install_tasks


task :chmod do
  File.chmod(0775, 'lib/image_science/extension.so')
end

task :compile do
  `ruby ext/image_science/extconf.rb`
  `make`
  `mv image_science.so lib/image_science/extension.so`
end

task :build => [:compile, :chmod]
