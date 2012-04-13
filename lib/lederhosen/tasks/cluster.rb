##
# FINALLY, CLUSTER!
#

module Lederhosen
  class CLI

    desc "cluster fasta file",
         "--input=sorted.fasta --identity=0.80 --output=clusters.uc"

    method_option :input,    :type => :string,  :default => 'sorted.fasta'
    method_option :output,   :type => :string,  :default => 'clusters.uc'
    method_option :identity, :type => :numeric, :default => 0.8

    def cluster
      identity = options[:identity]
      output = options[:output]
      input = options[:input]
    
      cmd = [
        'uclust',
        "--input #{input}",
        "--uc #{output}",
        "--id #{identity}",
      ].join(' ')
      exec cmd
    end

  end
end