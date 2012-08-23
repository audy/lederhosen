##
# FILTER READS WITH LOW ABUNDANCE KMERS
#

module Lederhosen
  class CLI

    desc "k_filter",
         "filter novel reads likely to form small/singleton clusters (experimental)"

    method_option :input,    :type => :string,  :required => true
    method_option :output,   :type => :string,  :required => true
    method_option :k,        :type => :numeric, :required => true
    method_option :cutoff,   :type => :numeric, :required => true

    def k_filter
      input  = options[:input]
      output = options[:output]
      k_len  = options[:k].to_i
      cutoff = options[:cutoff]

      ohai "kmer filtering #{input} (k = #{k_len}, cutoff = #{cutoff})"

      counting_table = Hash.new { |h, k| h[k] = 0 }
      total_reads = 0

      File.open(input) do |handle|
        pbar = ProgressBar.new 'counting', File.size(input)
        records = Dna.new handle
        records.each do |r|
          pbar.inc(handle.pos)
          total_reads += 1
          kmers = r.sequence.to_kmers(k_len)
          kmers.each { |x| counting_table[x] += 1 }
        end
        pbar.finish
      end

      sum_of_kmers = counting_table.values.inject(:+)

      ohai "total reads = #{total_reads}"
      ohai "sum of kmers = #{sum_of_kmers}"

      kept = 0
      total_reads = total_reads.to_f

      pbar = ProgressBar.new "saving", total_reads.to_i
      output = File.open(output, 'w')
      File.open(input) do |handle|
        records = Dna.new handle
        records.each do |r|
          kmers = r.sequence.to_kmers(k_len)

          # check if any of the kmers are rare
          keep = true
          coverage = 0
          kmers.each do |kmer|
            # if any of the kmers are rare, don't print the read
            c = counting_table[kmer]
            coverage += c
            if c < cutoff
              keep = false
              break
            end
          end

          if keep
            kept += 1
            output.puts r
          end
          pbar.inc
        end
      end

      pbar.finish

      ohai "survivors = #{kept} (#{kept/total_reads.to_f})"
      output.close
    end
  end

end
