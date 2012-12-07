require 'rubygems'
require 'bundler'
require 'set'
require 'dna'
require 'progressbar'
require 'thor'

Dir.glob(File.join(File.dirname(__FILE__), 'lederhosen', '*.rb')).each { |f| require f }

##
# Here I extend the string class to add the to_kmers method
#
# Does it really need to be a method of String? Sure, why not?
#
class String
  def to_kmers(k)
    return [] if k == 0
    k -= 1
    (0..(self.length-k-1)).collect { |i| self[i..i+k] }
  end
end
