require 'bundler'
Bundler::GemHelper.install_tasks

task :build => [:compile, :chmod]

task :compile do
  `ruby ext/image_science/extconf.rb`
  `make`
  `mv extension.so lib/image_science/extension.so`
end

task :chmod do
  File.chmod(0775, 'lib/image_science/extension.so')
end

