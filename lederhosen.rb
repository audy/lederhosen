#!/usr/bin/env ruby

require 'rubygems'
require 'thor'
require 'dna'

class Lederhosen < Thor

  ##
  # QUALITY TRIMMING
  #
  desc "trim", "trim sequences in raw_reads/ saves to trimmed/"
  method_options :raw_reads => :string
  def trim
    raw_reads = options[:raw_reads] || 'spec/data/*'
    `mkdir -p trimmed/`
    raw_reads = Helpers.get_grouped_qseq_files raw_reads
    puts "found #{raw_reads.length} pairs of reads"
    puts "trimming!"
    raw_reads.each do |a|
      out = File.join('trimmed/', "#{File.basename(a[0])}.fasta")
      Helpers.trim_pairs a[1][0], a[1][1], out, :min_length => 70
    end
  end

  ##
  # PAIRED-END READ WORK-AROUND (JOIN THEM)
  #
  desc "join", "join trimmed reads back to back"
  def join
    puts "joining!"
    `mkdir -p joined/`
    trimmed = Dir['trimmed/*.fasta']
    output = File.open('joined/joined.fasta', 'w')
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
  desc "sort", "sort joined reads by length"
  def sort
    `uclust --sort joined/joined.fasta --output sorted.fasta`
  end

  ##
  # FINALLY, CLUSTER!
  #
  desc "cluster", "cluster sorted joined reads"
  method_options :id => :float, :out => :string
  def cluster
    identity = options[:identity] || 0.8
    output = options[:output] || 'clusters.txt'
    cmd = [
      'uclust',
      '--input sorted.fasta',
      "--uc #{output}",
      "--id #{identity}",
    ].join(' ')
    exec cmd
  end

  ##
  # MAKE TABLES
  #
  desc "tables", "generate tables"
  method_options :input => :string
  def tables
    input = options[:input] || 'clusters.txt'
    clusters = Hash.new

    # Load cluster table!
    clusters = Helpers.load_uc_file(input)

    clusters_total = clusters.values.collect{ |x| x[:count] }.inject(:+)

    # Get representative sequences!
    reads_total = 0
    representatives = {}
    clusters.each{ |k, x| representatives[x[:seed]] = k }

    output = File.open('representatives.fasta', 'w')

    File.open('joined/joined.fasta') do |handle|
      records = Dna.new handle
      records.each do |dna|
        reads_total += 1
        if !representatives[dna.name].nil?
          dna.name = "#{dna.name}:cluster_#{representatives[dna.name]}"
          output.puts dna
        end
      end
    end

    output.close

    # Print some statistics
    puts "reads in clusters:  #{clusters_total}"    
    puts "number of reads:    #{reads_total}"
    puts "unique clusters:    #{clusters.keys.length}"

    # TODO: Shannon diversity index (for each sample...)
    
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
    dna.sequence[start, _end - start].gsub('.', 'N') rescue nil
  end

  # Load uc file from uclust
  # returns hash
  # { "cluster_number" => { :seed => "seed_fasta_header", :count => "number of pairs" } }
  def load_uc_file(input)
    clusters = Hash.new
    File.open(input) do |handle|
      handle.each do |line|
        next if line =~ /^#/
        line = line.strip.split
        type = line[0]
        clusternr = line[1]
        querylabel = line[8]
        targetlabel = line[9]
        # SEED CLUSTER
        if type == 'S'
          clusters[clusternr] = { :seed => querylabel, :count => 1 }
        elsif type == 'H'
          clusters[clusternr][:count] += 1
        end
      end
    end
    clusters
  end
  end # class << self
end

Lederhosen.start if __FILE__ == $0