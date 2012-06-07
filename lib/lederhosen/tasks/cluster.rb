##
# FINALLY, CLUSTER!
#

module Lederhosen
  class CLI

    desc "cluster",
         "--input=sorted.fasta --identity=0.80 --output=clusters.uc"

    method_option :input,    :type => :string,  :required => true
    method_option :output,   :type => :string,  :required => true
    method_option :identity, :type => :numeric, :required => true

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