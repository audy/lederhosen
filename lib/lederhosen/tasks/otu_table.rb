##
# MAKE TABLES
#

module Lederhosen
  class CLI

    desc "otu_table",
         "create an OTU abundance matrix from taxonomy count files"

    method_option :files,  :type => :string, :required => true
    method_option :level,  :type => :string, :required => true
    method_option :output, :type => :string, :required => true

    def otu_table
      inputs = Dir[options[:files]]
      level  = options[:level].downcase
      output = options[:output]

      ohai "Generating OTU matrix from #{inputs.size} inputs at #{level} level and saving to #{output}."

      # sanity check
      fail "bad level: #{level}" unless %w{domain phylum class order family genus species kingdom original}.include? level      
      fail 'no inputs matched your glob' if inputs.size == 0

      sample_cluster_count = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = 0 } }

      # create a progress bar with the total number of bytes of
      # the files we're slurping up
      pbar = ProgressBar.new "loading", inputs.size

      inputs.each do |input_file|
        File.open(input_file).each do |line|
          next if line =~ /^#/ # skip header(s)
          line = line.strip.split(',')
          taxonomy, count = line
          count = count.to_i
          tax =
            if taxonomy == 'unclassified_reads'
              'unclassified_reads'
            else
              parse_taxonomy(taxonomy)[level]
            end
          sample_cluster_count[input_file][tax] += count
        end
        pbar.inc
      end
      pbar.finish

      all_clusters = sample_cluster_count.values.map(&:keys).flatten.uniq.sort

      out = File.open(output, 'w')
      
      out.puts all_clusters.join(',')
      inputs.sort.each do |input|
        out.print "#{input}"
        all_clusters.each do |c|
          out.print ",#{sample_cluster_count[input][c]}"
        end
        out.print "\n"
      end

    end

  end # class CLI
end # module Lederhosen
