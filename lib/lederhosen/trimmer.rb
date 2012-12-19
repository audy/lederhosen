module Lederhosen
module Trimmer

##
# Code used for sequence trimming
#
# - PairedTrimmer
# - SequenceTrimmer
# - ProbabilityTrimmer
# - QSEQTrimmer
#
# Some major refactoring needs to get done here
#

# class that has the trim function. Used in mixins
# this trim function is based on the function documented
# in the paper by Wang, et al [citation needed].
class WangTrimmer

  def initialize(args={})
    @min = args[:min]
    @offset = args[:offset]
  end

  def trim_seq(dna)

    _sum, _max, first, last, start, _end = 0, 0, 0, 0, 0

    dna.quality.each_byte.each_with_index do |b, a|
      _sum += (b - @offset - @min)
      if _sum > _max
        _max = _sum
        _end = a
        start = first
      elsif _sum < 0
        _sum = 0
        first = a
      end
    end

    begin
      dna.sequence[start, _end - start].gsub('.', 'N')
    rescue
      nil
    end
  end
end

# return the longest string starting from the left side
# where the probability of error as computer from the PHRED
# scores does not fall below a certain cutoff
# (default is 0.05)
class ProbabilityTrimmer

  def initialize(args = {})
    @cutoff = args[:cutoff] || 0.005
    @min = args[:min]
    @seqtech = args[:seq_tech] || fail
    # must be illumina, sanger or solexa
  end

  def trim_seq(dna)
    trim_coord = dna.sequence.size
    probabilities = dna.send(:"#{@seqtech}_probabilities")
    probabilities.each_with_index do |q, i|
      if q > @cutoff
        trim_coord = i
        break
      end
    end

    begin
      dna.sequence[0..trim_coord].gsub('.', 'N')
    rescue
      nil
    end
  end
end

# Base class for trimming paired-end reads
class PairedTrimmer < Enumerator

  def initialize(args = {})
    @pretrim    = args[:pretrim]
    # TODO
    # need to be able to trim from left, right of pairs
    # thinking about specifying a "trimming language"
    #
    # Something like:
    #
    # --trim="5L0 0L3"
    # --trim="0L4 2L6"
    #
    # also thinking about breaking all of this trimming stuff
    # out into its own package. (to be more unixy and stuff ;)
    
    @min_length = args[:min_length] || 70
    @min        = args[:min] || 20
    @offset     = args[:cutoff] || 64 # XXX should both be called 'cutoff'
    @left_trim  = args[:left_trim] || 0 # trim adapter sequence
    @trimmer    = args[:trimmer] || ProbabilityTrimmer.new(:min => @min,
                                                           :offset => @offset,
                                                           :seq_tech =>
                                                           :illumina)
  end

  def each(&block)
    skipped_because_singleton = 0
    skipped_because_length = 0
    @paired_iterator.each_with_index do |a, i|
      seqa = @trimmer.trim_seq(a[0])[@left_trim..-1] rescue nil # trim adapter sequence
      seqb = @trimmer.trim_seq a[1]
      if [seqa, seqb].include? nil
        skipped_because_singleton += 1
      elsif !(seqb.length >= @min_length && seqa.length >= @min_length)
        skipped_because_length += 1
      else # reads are good
        seqb = reverse_complement(seqb) # experiment-specific?
        a = Fasta.new :name => "#{i}:0", :sequence => seqa
        b = Fasta.new :name => "#{i}:1", :sequence => seqb
        block.yield a
        block.yield b
      end
    end
  end

  # reverse complement a DNA sequence
  # assumes only GATCN nucleotides
  def reverse_complement(s)
    s.reverse.tr('GATCNgatcn','CTAGNctagn')
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
    @paired_iterator = reads.each_slice(2)

    super(args)
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

    @paired_iterator = left_file_reads.zip(right_reads)

    super(args)

    left_handle.close
    right_handle.close
  end
end

end # module Trimmer
end # module Lederhosen
