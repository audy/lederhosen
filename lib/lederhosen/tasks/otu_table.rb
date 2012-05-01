##
# MAKE TABLES
#

SEP = ','

module Lederhosen
  class CLI

    desc "otu_tables generates otu tables",
         "--clusters=clusters.uc --output=otu_prefix"

    method_option :clusters, :type => :string, :required => true
    method_option :output,   :type => :string, :required => true

    def otu_table
      input        = options[:clusters]
      output       = options[:output]
      joined_reads = options[:joined]
      

      # Load cluster table!
      clstr_info      = Helpers.load_uc_file input     
      clstr_counts    = clstr_info[:clstr_counts] # clstr_counts[:clstr][sample.to_i] = reads
      clstrnr_to_seed = clstr_info[:clstrnr_to_seed]
      samples         = clstr_info[:samples]

      # print OTU abundancy matrix
      
      File.open("#{output}.csv", 'w') do |h|
        samples  = samples.sort
        clusters = clstr_counts.keys

        # print header
        head = samples.join(SEP)
        h.puts "-" + SEP + head

        # start printing clusters
        clusters.each do |cluster|
          h.print "cluster-#{cluster}"
          samples.each do |sample|
            h.print "#{SEP}#{clstr_counts[cluster][sample]}"
          end
          h.print "\n"
        end
          
      end

      # # Get representative sequences!
      # reads_total = 0
      # representatives = {}
      # clusters[:count_data].each{ |k, x| representatives[x[:seed]] = k }
      # 
      # out_handle = File.open("#{output}.fasta", 'w')
      # 
      # File.open(joined_reads) do |handle|
      #   records = Dna.new handle
      #   records.each do |dna|
      #     reads_total += 1
      #     if !representatives[dna.name].nil?
      #       dna.name = "#{dna.name}:cluster_#{representatives[dna.name]}"
      #       out_handle.puts dna
      #     end
      #   end
      # end
      # 
      # out_handle.close
      # 
      # # Print some statistics
      # ohai "reads in clusters:  #{clusters_total}"    
      # ohai "number of reads:    #{reads_total}"
      # ohai "unique clusters:    #{clusters.keys.length}"



    end

  end
end