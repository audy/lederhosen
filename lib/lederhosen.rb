require 'rubygems'
require 'bundler'
require 'set'
require 'dna'
require 'progressbar'
require 'thor'

Dir.glob(File.join(File.dirname(__FILE__), 'lederhosen', '*.rb')).each { |f| require f }
