require 'rubygems'
require 'thor'
require 'dna'
require 'set'
require 'progressbar'
require 'awesome_print'

Dir.glob(File.join(File.dirname(__FILE__), 'lederhosen', '*.rb')).each { |f| require f }

class String
  def to_kmers(k)
    return [] if k == 0
    k -= 1
    (0..(self.length-k-1)).collect { |i| self[i..i+k] }
  end
end