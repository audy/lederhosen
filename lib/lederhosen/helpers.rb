module Lederhosen
  class Helpers
    class << self

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

    # Load uc file from uclust
    # returns hash with various data
    def load_uc_file(input)
      clusters = Hash.new

      # keep track of samples
      samples = Set.new

      # store a list of all the sample IDs
      clusters[:samples] = Set.new

      # data for each cluster
      # clstr_counts[:clstr][:sample] = number_of_reads
      clstr_counts = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = 0 } }

      # clstrnr_to_seed[seed_sequence_id] = clstr_nr
      seed_to_clstrnr = Hash.new
      bytes = File.size(input)
      pbar = ProgressBar.new 'loading uc file', bytes
      File.open(input) do |handle|
        handle.each do |line|
          pbar.set handle.pos
          next if line =~ /^#/ # skip comments

          line = line.strip.split

          # things we want to know
          type        = line[0]
          clusternr   = line[1].to_i
          querylabel  = line[8]
          targetlabel = line[9]
          header      = line[8]

          sample =
            begin
              # get the sample id via regexp match
              # this way more info can be stored in the header.
              line[8].match(/sample=(.*)/)[1]
            rescue NoMethodError # catch no method [] for NilClass
              # Need to maintain some backwards compatibility here
              # this is the old way of getting the same id.
              sample = line[8].split(':')[2]
            end

          # keep track of samples
          samples.add(sample)

          # keep track of all samples
          clusters[:samples].add sample

          # L=LibSeed
          # S=NewSeed
          # H=Hit
          # R=Reject
          # D=LibCluster
          # C=NewCluster
          # N=NoHit

          if type =~ /[LS]/ # = Seed Sequence
            clstr_counts[clusternr][sample] += 1
            seed_to_clstrnr[querylabel] = clusternr
          elsif type =~ /H/ # = Seed Member
            clstr_counts[clusternr][sample] += 1
          end

        end
      end
      pbar.finish
      return {
        :clstr_counts    => clstr_counts,
        :seed_to_clstrnr => seed_to_clstrnr,
        :samples         => samples
      }
    end


    end # class << self
  end # class Helpers
end # Module
