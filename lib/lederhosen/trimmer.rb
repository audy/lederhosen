module Lederhosen
module Trimmer

# Base class for trimming paired-end reads
class PairedTrimmer < Enumerator
  def initialize(paired_iterator, args = {})
    @paired_iterator = paired_iterator
    @pretrim         = args[:pretrim]
    @min_length      = args[:min_length] || 70
  end

  def each(&block)
    @paired_iterator.each_with_index do |a, i|
      seqa = trim_seq a[0], :pretrim => @pretrim
      seqb = trim_seq a[1], :pretrim => @pretrim
      unless [seqa, seqb].include? nil
        if seqb.length >= @min_length && seqa.length >= @min_length
          seqb = reverse_complement(seqb) # experiment-specific?
          a = Fasta.new :name => "#{i}:0", :sequence => seqa
          b = Fasta.new :name => "#{i}:1", :sequence => seqb
          block.yield a
          block.yield b
        else # we just skip bad reads entirely
          next
        end
      else
        next
      end
    end
  end

  # reverse complement a DNA sequence
  # assumes only GATCN nucleotides
  def reverse_complement(s)
    s.reverse.tr('GATCNgatcn','CTAGNctagn')
  end

  # this method does the actual trimming. It is a class method
  # so you can use it if you don't want to initialize a PairedTrimmer
  def trim_seq(dna, args={})
    pretrim = args[:pretrim] || false

    # trim primers off of sequence
    # XXX this is experiment-specific and needs to be made
    # into a parameter
    if pretrim
      dna.sequence = dna.sequence[pretrim..-1]
      dna.quality  = dna.quality[pretrim..-1]
    end

    dna.sequence.gsub! '.', 'N'

    min    = args[:min]    || 20 # what is this constant?
    offset = args[:cutoff] || 64 # XXX depends on sequencing tech.

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

    dna.sequence[start, _end - start] rescue nil
  end

end

#
# Yields trimmed fasta records given an input
# interleaved, paired-end fastq file
class InterleavedTrimmer < PairedTrimmer

  def initialize(interleaved_file, args = {})
    # create an iterator that yields paired records
    # as an array

    handle =
      begin
        Zlib::GzipReader.open(interleaved_file)
      rescue Zlib::GzipFile::Error
        File.open(interleaved_file)
      end

    reads = Dna.new handle
    iterator = reads.each_slice(2)

    super(iterator, args)

  end
end

# Yield trimmed fasta records given an two separate
# paired QSEQ files
class QSEQTrimmer < PairedTrimmer
  def initialize(left_file, right_file, args = {})
    # create an iterator that yields paired records
    # as an array

    left_handle, right_handle =
      begin
        [ Zlib::GzipReader.open(left_file), Zlib::GzipReader.open(right_file)]
      rescue Zlib::GzipFile::Error
        [ File.open(left_file), File.open(right_file) ]
      end

    left_file_reads  = Dna.new left_handle
    right_reads = Dna.new right_handle

    iterator = left_file_reads.zip(right_reads)

    super(iterator, args)

    left_handle.close
    right_handle.close
  end
end

end # module Trimmer
end # module Lederhosen
