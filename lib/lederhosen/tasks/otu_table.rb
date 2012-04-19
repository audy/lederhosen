##
# MAKE TABLES
#

module Lederhosen
  class CLI

    desc "otu_tables generates otu tables & representative reads",
         "--clusters=clusters.uc --output=otu_prefix --joined=joined.fasta"

    method_option :clusters, :type => :string, :required => true
    method_option :output,   :type => :string, :required => true
    method_option :joined,   :type => :string, :required => true

    def otu_table
      input = options[:clusters]
      output = options[:output]
      joined_reads = options[:joined]

      clusters = Hash.new

      # Load cluster table!
      clusters = Helpers.load_uc_file(input)

      clusters_total = clusters[:count_data].values.collect{ |x| x[:total] }.inject(:+)

      # Get representative sequences!
      reads_total = 0
      representatives = {}
      clusters[:count_data].each{ |k, x| representatives[x[:seed]] = k }

      out_handle = File.open("#{output}.fasta", 'w')

      File.open(joined_reads) do |handle|
        records = Dna.new handle
        records.each do |dna|
          reads_total += 1
          if !representatives[dna.name].nil?
            dna.name = "#{dna.name}:cluster_#{representatives[dna.name]}"
            out_handle.puts dna
          end
        end
      end

      out_handle.close

      # Print some statistics
      ohai "reads in clusters:  #{clusters_total}"    
      ohai "number of reads:    #{reads_total}"
      ohai "unique clusters:    #{clusters.keys.length}"

      # print OTU abundancy matrix
      csv = Helpers.cluster_data_as_csv(clusters)
      File.open("#{output}.csv", 'w') do |h|
        h.puts csv
      end

    end

  end
end