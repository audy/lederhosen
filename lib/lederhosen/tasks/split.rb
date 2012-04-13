##
# Create a fasta file with nucleotide sequences for each cluster larger than a cutoff
#

module Lederhosen
  class CLI

    desc "output separate fasta file containing sequences belonging to each cluster",
         "--clusters=clusters.uc --reads=joined.fasta --min-clst-size=100"

    method_option :clusters,      :type => :string,  :default => 'clusters.uc'
    method_option :reads,         :type => :string,  :default => 'joined.fasta'
    method_option :out_dir,       :type => :string,  :default => 'clusters_split'
    method_option :buffer_size,   :type => :numeric, :default => 1000
    method_option :min_clst_size, :type => :numeric, :default => 100

    def split
      clusters = options[:clusters]
      reads    = options[:reads]
      out_dir  = options[:out_dir]
      buffer_size = options[:buffer_size]
      min_clst_size = options[:min_clst_size]
      finalize_every = 100_000

      `mkdir -p #{out_dir}/`

      ohai "loading #{clusters}"

      # Load read id -> cluster
      read_to_clusterid = Hash.new

      # keep track of cluster sizes
      cluster_counts    = Hash.new { |h, k| h[k] = 0}

      File.open(clusters)do |handle|
        handle.each do |line|
          line = line.strip.split
          cluster_nr = line[1]
          if line[0] == 'S' || line[0] == 'H'
            read = line[8]
          else
            next
          end
          read_to_clusterid[read] = cluster_nr
          cluster_counts[cluster_nr] += 1
        end
      end

      read_to_clusterid.delete_if do |read, cluster_nr|
        cluster_counts[cluster_nr] < min_clst_size
      end

      total_reads = read_to_clusterid.length
      total_clusters = read_to_clusterid.values.uniq.length
      ohai "#{total_reads} reads in #{total_clusters} clusters"

      pbar = ProgressBar.new "saving", total_reads

      # Write reads to individual fasta files using Buffer
      buffer = Buffer.new :buffer_max => buffer_size
      File.open(reads) do |handle|
        records = Dna.new handle
        records.each_with_index do |record, i|
          cluster_id = read_to_clusterid[record.name]
          if cluster_id
            pbar.inc
            filename = File.join(out_dir, cluster_id + '.fasta')
            buffer[filename] << record
            buffer.finalize if (i%finalize_every == 0)
          end
        end
      end

      pbar.finish
      ohai "finalizing output"
      buffer.finalize # finish writing out

      puts "done"
    end
  end
end