##
# SORT JOINED READS BY LENGTH
#

module Lederhosen
  class CLI

    desc "sort",
         "sort reads by length in descending order (pre-requisite for UCLUST)"

    method_option :input,  :type => :string, :required => true
    method_option :output, :type => :string, :required => true

    def sort
      input = options[:input]
      output = options[:output]
      @shell.mute {
        run "uclust --mergesort #{input} --output #{output}"
      }
    end
  end
end
