##
# FINALLY, CLUSTER!
#

module Lederhosen
  class CLI

    desc "cluster",
         "cluster a fasta file using UCLUST"

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
