##
# MAKE TABLES
#

SEP = ','

module Lederhosen
  class CLI

    desc "otu_table",
         "create an OTU abundance matrix from UCLUST output"

    method_option :clusters, :type => :string, :required => true
    method_option :output,   :type => :string, :required => true

    def otu_table
      input        = options[:clusters]
      output       = options[:output]
      joined_reads = options[:joined]

      # Load cluster table

      clstr_info      = Helpers.load_uc_file input
      clstr_counts    = clstr_info[:clstr_counts] # clstr_counts[:clstr][sample.to_i] = reads
      clstrnr_to_seed = clstr_info[:clstrnr_to_seed]
      samples         = clstr_info[:samples]

      # print OTU abundance matrix
      # clusters as columns
      # samples as rows

      File.open("#{output}.csv", 'w') do |h|
        samples  = samples.sort
        clusters = clstr_counts.keys

        # print header (cluster names)
        h.puts '-' + SEP + clusters.map { |x| "cluster-#{x}" }.join(SEP)

        samples.each do |sample|
          h.print sample
          clusters.each do |cluster|
            h.print "#{SEP}#{clstr_counts[cluster][sample]}"
          end
          h.print "\n"
        end
      end
    end

  end
end
