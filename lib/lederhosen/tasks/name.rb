##
# IDENTIFY CLUSTERS IN A TAXCOLLECTOR DATABASE
#

module Lederhosen
  class CLI

    desc "name",
         "--reps representative_reads.fasta --database taxcollector.fa --output blast_like_output.txt"

    method_option :reps,     :type => :string, :required => true
    method_option :database, :type => :string, :required => true
    method_option :output,   :type => :string, :required => true

    def name
      reps     = options[:reps]
      database = options[:database]
      output   = options[:output]

      # run blat/blast
      cmd = [
        'blat',
        database,
        reps,
        '-t=dna',
        '-q=dna',
        '-out=blast8',
        output      
      ]
      
      exec cmd.join(' ')

    end

  end
end