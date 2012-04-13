#!/usr/bin/env ruby

require 'rubygems'
require 'thor'
require 'dna'
require 'set'
require 'progressbar'

fail "you need to install uclust and have it in your $PATH" if `which uclust` == ''

class Lederhosen < Thor

  ##
  # QUALITY TRIMMING
  #
  desc "trim Illumina QSEQ files", "--reads_dir=reads/* --out_dir=trimmed.fasta"
  method_options :reads_dir => :string, :out_dir => :string
  def trim
    
    raw_reads = options[:reads_dir]
    out_dir = options[:out_dir] || 'trimmed/'
    
    `mkdir -p #{out_dir}`
    
    raw_reads = Helpers.get_grouped_qseq_files raw_reads
    puts "found #{raw_reads.length} pairs of reads"
    puts "trimming!"
    raw_reads.each do |a|
      out = File.join(out_dir, "#{File.basename(a[0])}.fasta")
      # TODO get total and trimmed
      total, trimmed = Helpers.trim_pairs a[1][0], a[1][1], out, :min_length => 70
    end
  end

  ##
  # PAIRED-END READ WORK-AROUND (JOIN THEM)
  #
  desc "join reads end-to-end", "--trimmed=trimmed/*.fasta --output=joined.fasta"
  method_options :trimmed => :string, :output => :string
  def join
    puts "joining!"

    trimmed = Dir[options[:trimmed] || 'trimmed/*.fasta']
    output = options[:output] || 'joined.fasta'

    fail "no reads in #{trimmed}" if trimmed.length == 0

    output = File.open(output, 'w')
    trimmed.each do |fasta_file|
      records = Dna.new File.open(fasta_file)
      records.each_slice(2) do |r, l|
        output.puts ">#{r.name}:#{File.basename(fasta_file, '.fasta')}\n#{r.sequence.reverse+l.sequence}"
      end
    end
  end

  ##
  # SORT JOINED READS BY LENGTH
  #
  desc "sort fasta file by length", "--input=joined.fasta --output=sorted.fasta"
  method_options :input => :string, :output => :string
  def sort
    input = options[:input] || 'joined.fasta'
    output = options[:output] || 'sorted.fasta'
    `uclust --mergesort #{input} --output #{output}`
  end

  ##
  # FINALLY, CLUSTER!
  #
  desc "cluster fasta file", "--input=sorted.fasta --identity=0.80 --output=clusters.uc"
  method_options :input => :string, :output => :string, :identity => :float
  def cluster
    identity = options[:identity] || 0.8
    output = options[:output] || 'clusters.uc'
    input = options[:input] || 'sorted.fasta'
    
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
  method_options :clusters => :string, :output => :string, :joined => :string
  def otu_table
    input = options[:clusters] || 'clusters.uc'
    output = options[:output] || 'otus'
    joined_reads = options[:joined] || 'joined.fasta'

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
    puts "reads in clusters:  #{clusters_total}"    
    puts "number of reads:    #{reads_total}"
    puts "unique clusters:    #{clusters.keys.length}"

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
  method_options :clusters => :string, :reads=> :string, :buffer_size => :int, :min_clst_size => :int
  def split
    clusters = options[:clusters] || 'clusters.uc'
    reads    = options[:reads]    || 'joined.fasta'
    out_dir  = options[:out_dir]        || 'clusters_split'
    buffer_size = (options[:buffer_size] || 1000).to_i
    min_clst_size = (options[:min_clst_size] || 100).to_i
    finalize_every = 100_000

    `mkdir -p #{out_dir}/`

    puts "loading #{clusters}"

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
    puts "#{total_reads} reads in #{total_clusters} clusters"

    puts "writing out fasta files"
    
    pbar = ProgressBar.new "writing", total_reads

    # Write reads to individual fasta files using Buffer
    buffer = Buffer.new :buffer_max => buffer_size
    File.open(reads) do |handle|
      records = Dna.new handle
      $stderr.puts "reads = #{reads}"
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
    puts "finalizing output"
    buffer.finalize # finish writing out

    puts "done"
  end
  
end

class Helpers
  class << self

  # Function for grouping qseq files produced by splitting illumina
  # reads by barcode
  #
  # Filenames should look like this:
  # IL5_L_1_B_007_1.txt
  def get_grouped_qseq_files(glob='raw_reads/*.txt')
    Dir.glob(glob).group_by { |x| x.split('_')[0..4].join('_') }
  end

  # Trim a pair of QSEQ files. Saves to a single,
  # interleaved .fasta file
  def trim_pairs(left, right, out, args={})
    cutoff = args[:cutoff] || 20
    min_length = args[:min_length] || 70

    left_handle  = File.open left
    right_handle = File.open right
    out_handle   = File.open out, 'w'

    left_reads  = Dna.new left_handle
    right_reads = Dna.new right_handle

    i = 0
    left_reads.zip(right_reads).each do |a, b|
      i += 1
      seqa = trim a
      seqb = trim b
      unless [seqa, seqb].include? nil
        if seqb.length >= min_length && seqa.length >= min_length
          out_handle.puts ">#{i}:0\n#{seqa}\n>#{i}:1\n#{seqb}"
        end
      end
    end
    left_handle.close
    right_handle.close
    out_handle.close
  end

  # Return longest subsequence with quality scores
  # greater than min. (Illumina PHRED)
  # Trim2 from Huang, et. al
  # returns just the sequence
  def trim(dna, args={})

    min = args[:min] || 20
    offset = args[:cutoff] || 64
    _sum, _max, first, last, start, _end = 0, 0, 0, 0, 0
    dna.quality.each_byte.each_with_index do |b, a|
      _sum += (b - offset - min)
      if _sum > _max
        _max = _sum
        _end = a
        start = first
      elsif _sum < 0
        _sum = 0
        first = a
      end
    end
    dna.sequence[start + 11, _end - start].gsub('.', 'N') rescue nil
  end

  # Load uc file from uclust
  # returns hash with various data
  def load_uc_file(input)
    clusters = Hash.new

    # store a list of samples
    clusters[:samples] = Set.new

    # data for each cluster
    # - total size
    # - size by sample
    # - seed sequence
    clusters[:count_data] = Hash.new

    File.open(input) do |handle|
      handle.each do |line|

        # skip comments
        next if line =~ /^#/
        line = line.strip.split

        # things we want to know
        type        = line[0]
        clusternr   = line[1]
        querylabel  = line[8]
        targetlabel = line[9]
        sample      = line[8].split(':')[2]

        # keep track of all samples
        clusters[:samples] << sample

        if type == 'S' # = Seed Sequence
          clusters[:count_data][clusternr] = { :seed => querylabel, :total => 1, :counts => Hash.new{ |h, k| h[k] = 0 } }
        elsif type == 'H' # = Seed Member
          clusters[:count_data][clusternr][:total] += 1
          clusters[:count_data][clusternr][:counts][sample] += 1
        end

      end
    end
    clusters
  end

  def cluster_data_as_csv(data)
    samples = data[:samples].to_a
    counts = data[:count_data]

    sep = "\t"
    csv = []
    csv << ['-'] + samples
    counts.keys.each do |cluster|
      csv << ["cluster-#{cluster}"] + samples.collect { |x| "#{counts[cluster][:counts][x]}" }
    end
    csv.collect { |x| x.join("\t")}.join("\n")
  end

  end # class << self
end

class Buffer
  # for when you need to write out to a shitload of files.

  #
  # Create a new buffer
  #
  def initialize(args={})
    @buffer = Hash.new { |h, k| h[k] = Array.new }
    @buffer_max = args[:buffer_max] || 100_000
  end

  #
  # Add an object to the buffer
  #
  def add_to bucket, obj

    @buffer[bucket] << obj.to_s

    if @buffer[bucket].length > @buffer_max
      # write out
      File.open(bucket, 'a+') do |out|
        @buffer[bucket].each do |v|
          out.puts v
        end
      end

      # clear that bucket
      @buffer[bucket].clear
    end
  end

  def [] k
    @buffer[k]
  end

  #
  # Writes out leftover objects
  #
  def finalize
    @buffer.each_key do |bucket|
      File.open(bucket, 'a+') do |out|
        @buffer[bucket].each do |v|
          out.puts v
        end
      end
    end
    @buffer = Hash.new { |h, k| h[k] = Array.new }
  end

end


Lederhosen.start if __FILE__ == $0
