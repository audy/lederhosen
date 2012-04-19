##
# SORT JOINED READS BY LENGTH
#

module Lederhosen
  class CLI

    desc "sort fasta file by length",
         "--input=joined.fasta --output=sorted.fasta"

    method_option :input,  :type => :string, :required => true
    method_option :output, :type => :string, :required => true

    def sort
      input = options[:input]
      output = options[:output]
      `uclust --mergesort #{input} --output #{output}`
    end

  end
end