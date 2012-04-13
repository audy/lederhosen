module Lederhosen
  class CLI < Thor
  
    ##
    # QUALITY TRIMMING
    #
    desc "trim Illumina QSEQ files", "--reads_dir=reads/* --out_dir=trimmed.fasta"
    method_option :reads_dir, :type => :string, :required => true
    method_option :out_dir,   :type => :string, :default => 'trimmed/'
    def trim

      raw_reads = options[:reads_dir]
      out_dir = options[:out_dir]

      `mkdir -p #{out_dir}`

      raw_reads = Helpers.get_grouped_qseq_files raw_reads
      ohai "found #{raw_reads.length} pairs of reads"

      pbar = ProgressBar.new "trimming", raw_reads.length

      raw_reads.each do |a|
        pbar.inc
        out = File.join(out_dir, "#{File.basename(a[0])}.fasta")
        # TODO get total and trimmed
        total, trimmed = Helpers.trim_pairs a[1][0], a[1][1], out, :min_length => 70
      end

      pbar.finish
    end

    ##
    # PAIRED-END READ WORK-AROUND (JOIN THEM)
    #
    desc "join reads end-to-end", "--trimmed=trimmed/*.fasta --output=joined.fasta"
    method_option :trimmed, :type => :string, :default => 'trimmed/*,fasta'
    method_option :output,  :type => :string, :default => 'joined.fasta'
    def join

      trimmed = Dir[options[:trimmed]]
      output = options[:output]

      fail "no reads in #{trimmed}" if trimmed.length == 0

      output = File.open(output, 'w')

      pbar = ProgressBar.new "joining", trimmed.length

      trimmed.each do |fasta_file|
        pbar.inc
        records = Dna.new File.open(fasta_file)
        records.each_slice(2) do |r, l|
          output.puts ">#{r.name}:#{File.basename(fasta_file, '.fasta')}\n#{r.sequence.reverse+l.sequence}"
        end
      end
      pbar.finish
    end

    ##
    # SORT JOINED READS BY LENGTH
    #
    desc "sort fasta file by length", "--input=joined.fasta --output=sorted.fasta"
    method_options :input => :string, :output => :string
    method_option :input,  :type => :string, :default => 'joined.fasta'
    method_option :output, :type => :string, :default => 'sorted.fasta'
    def sort
      input = options[:input]
      output = options[:output]
      `uclust --mergesort #{input} --output #{output}`
    end

    ##
    # FINALLY, CLUSTER!
    #
    desc "cluster fasta file", "--input=sorted.fasta --identity=0.80 --output=clusters.uc"
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

    ##
    # MAKE TABLES
    #
    desc "otu_tables generates otu tables & representative reads", "--clusters=clusters.uc --output=otu_prefix --joined=joined.fasta"
    method_option :clusters, :type => :string, :default => 'clusters.uc'
    method_option :output,   :type => :string, :default => 'otus'
    method_option :joined,   :type => :string, :default => 'joined.fasta'
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

    ##
    # Create a fasta file with nucleotide sequences for each cluster larger than a cutoff
    #
    desc "output separate fasta file containing sequences belonging to each cluster", "--clusters=clusters.uc --reads=joined.fasta --min-clst-size=100"
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

    no_tasks do
      # just print string to STDERR
      def ohai(s)
        $stderr.puts s
      end
    end

  end # class CLI

end # module