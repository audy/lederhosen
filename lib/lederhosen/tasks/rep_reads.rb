##
# GET REPRESENTATIVE READS
#

module Lederhosen
  class CLI

    desc "rep_reads",
         "output a fasta file containing representative reads for each cluster given a UCLUST output file and the joined reads file"

    method_option :clusters, :type => :string, :required => true
    method_option :output,   :type => :string, :required => true
    method_option :joined,   :type => :string, :required => true

    def rep_reads
      input        = options[:clusters]
      output       = options[:output]
      joined_reads = options[:joined]


      # Load cluster table!
      clstr_info      = Helpers.load_uc_file input
      clstr_counts    = clstr_info[:clstr_counts] # clstr_counts[:clstr][sample.to_i] = reads
      seed_to_clstrnr = clstr_info[:seed_to_clstrnr]
      samples         = clstr_info[:samples]

      out_handle = File.open("#{output}", 'w')

      File.open(joined_reads) do |handle|
        records = Dna.new handle
        records.each do |dna|
          clstrnr = seed_to_clstrnr[dna.name]
          unless clstrnr.nil?
            dna.name = "#{dna.name}:cluster-#{clstrnr}"
            out_handle.puts dna
          end
        end
      end

      out_handle.close
    end

  end
end
