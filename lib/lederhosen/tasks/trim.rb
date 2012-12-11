##
# QUALITY TRIMMING
#

# This should probably be broken into its own module or command-line utility.

module Lederhosen
  class CLI

    desc "trim",
         "trim reads based on quality scores"

    method_option :reads_dir, :type => :string, :required => true
    method_option :out_dir,   :type => :string, :required => true
    method_option :pretrim,   :type => :numeric, :default => 11

    def trim
      raw_reads = options[:reads_dir]
      out_dir   = options[:out_dir]
      pretrim   = options[:pretrim]

      ohai "trimming #{File.dirname(raw_reads)} and saving to #{out_dir}"

      run "mkdir -p #{out_dir}"

      raw_reads = get_grouped_qseq_files raw_reads

      ohai "found #{raw_reads.length} pairs of reads"

      pbar = ProgressBar.new "trimming", raw_reads.length
      raw_reads.each do |a|
        pbar.inc
        out = File.join(out_dir, "#{File.basename(a[0])}.fasta")
        # TODO get total and trimmed
        total, trimmed = trim_pairs a[1][0], a[1][1], out, :min_length => 70
      end
      pbar.finish

    end

    no_tasks do

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
          seqa = trim_seq a
          seqb = trim_seq b
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
      def trim_seq(dna, args={})


        pretrim = args[:pretrim] || false
        # trim primers off of sequence
        # XXX this is experiment-specific and needs to be made
        # into a parameter
        if pretrim
          dna.sequence = dna.sequence[pretrim..-1]
          dna.quality  = dna.quality[pretrim..-1]
        end

        # throw away any read with an ambiguous primer
        return nil if dna.sequence =~ /N/

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

        # XXX why is this rescue statement here?
        dna.sequence[start + 11, _end - start].gsub('.', 'N') rescue nil
      end
    end

  end
end
