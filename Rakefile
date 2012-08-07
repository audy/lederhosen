# encoding: utf-8

require 'rubygems'
require 'bundler'

require './lib/lederhosen/version.rb'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "lederhosen"
  gem.homepage = "http://github.com/audy/lederhosen"
  gem.license = "MIT"
  gem.summary = "OTU Clustering"
  gem.description = "Various tools for OTU clustering"
  gem.email = "harekrishna@gmail.com"
  gem.authors = ["Austin G. Davis-Richardson"]
  gem.version = Lederhosen::Version::STRING
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|

  version = Lederhosen::Version::STRING

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "test #{version}"
  rdoc.rdoc_files.include('readme.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
