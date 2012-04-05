#!/usr/bin/env ruby

require 'rubygems'
require 'thor'
require 'dna'
require 'zlib'

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

  end
end

class Lederhosen < Thor
  desc "trim", "trim sequences in raw_reads/ saves to trimmed/"
  def trim
    puts "trimming!"
    `mkdir -p trimmed/`
    raw_reads = Helpers.get_grouped_qseq_files 'spec/data/*'
    raw_reads.each do |a|
      out = File.join('trimmed/', "#{File.basename(a[0])}.fasta")
      Helpers.trim_pairs a[1][0], a[1][1], out, :min_length => 70
    end
  end

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

  desc "sort", "sort joined reads by length"
  def sort
    `uclust --sort joined/joined.fasta --output sorted.fasta`
  end

  desc "cluster", "cluster sorted joined reads"
  method_options :identity => :float, :output => :string
  def cluster
    identity = options[:identity] || 0.8
    output = options[:output] || 'clusters_80'
    cmd = [
      'uclust',
      '--input sorted.fasta',
      "--uc #{options[:output]}",
      "--id #{options[:identity]}",
    ].join(' ')
    exec cmd
  end
end

Munchen.start if __FILE__ == $0