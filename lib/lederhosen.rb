require 'rubygems'
require 'thor'
require 'dna'
require 'set'
require 'progressbar'

Dir.glob(File.join(File.dirname(__FILE__), 'lederhosen', '*.rb')).each { |f| require f }
