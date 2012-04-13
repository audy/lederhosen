##
# SORT JOINED READS BY LENGTH
#

module Lederhosen
  class CLI

    desc "sort fasta file by length",
         "--input=joined.fasta --output=sorted.fasta"

    method_options :input => :string, :output => :string
    method_option :input,  :type => :string, :default => 'joined.fasta'
    method_option :output, :type => :string, :default => 'sorted.fasta'

    def sort
      input = options[:input]
      output = options[:output]
      `uclust --mergesort #{input} --output #{output}`
    end

  end
end