module Lederhosen
  class Helpers
    class << self

    # reverse complement a DNA sequence
    # assumes only GATCN nucleotides
    def reverse_complement(s)
      s.reverse.tr('GATCNgatcn','CTAGNctagn')
    end

    # Function for grouping qseq files produced by splitting illumina
    # reads by barcode
    #
    # Filenames should look like this:
    # IL5_L_1_B_007_1.txt
    def get_grouped_qseq_files(glob='raw_reads/*.txt')
      Dir.glob(glob).group_by { |x| File.basename(x).split('_')[0..4].join('_') }
    end

    # Trim a pair of QSEQ files. Saves to a single,
    # interleaved .fasta file
    def trim_pairs(left, right, out, args={})
      cutoff     = args[:cutoff]     || 20
      min_length = args[:min_length] || 70

      left_handle, right_handle =
        begin
          [ Zlib::GzipReader.open(left), Zlib::GzipReader.open(right)]
        rescue Zlib::GzipFile::Error
          [ File.open(left), File.open(right) ]
        end

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
            seqb = reverse_complement(seqb)
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

      # trim primers off of sequence
      # (THIS IS EXPERIMENT-SPECIFIC)
      dna.sequence = dna.sequence[11..-1]
      dna.quality  = dna.quality[11..-1]

      # throw away any read with an ambiguous primer
      return nil if dna.sequence =~ /N/

      min    = args[:min]    || 20
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

    end # class << self
  end # class Helpers
end # Module
