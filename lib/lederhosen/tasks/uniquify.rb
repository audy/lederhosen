##
# uniquify - uniquify a fasta file, also output table with sequence_id -> number of reads
#

module Lederhosen
  class CLI
    desc 'uniquify',
      'uniquify a fasta file and generate a table with sequence_id -> abundance'

    method_option :input,     :type => :string, :required => true
    method_option :output,    :type => :string, :required => true
    method_option :table_out, :type => :string, :required => true

    def uniquify
      input     = options[:input]
      output    = options[:output]
      table_out = options[:table_out]

      ohai "uniquifying #{input} to #{output} w/ table #{table_out}"

      sequence_counts = Hash.new { |h, k| h[k] = 0 }

      out = File.open(output, 'w')

      no_records = `grep -c '^>' #{input}`.split.first.to_i
      pbar = ProgressBar.new 'loading', no_records
      File.open(input) do |handle|
        Dna.new(handle).each do |record|
          pbar.inc
          unless sequence_counts.has_key? record.sequence
            out.puts record
          end
          sequence_counts[record.sequence] += 1
        end
      end

      pbar.finish
      out.close

      # write table
      pbar = ProgressBar.new 'table', no_records
      File.open(table_out, 'w') do |out|
        sequence_counts.each_pair do |sequence, count|
          pbar.inc
          out.puts "#{sequence.name},#{count}"
        end
      end
      pbar.finish
      kept = sequence_counts.keys.size
      total = sequence_counts.values.inject(:+)
      ohai "kept #{kept} out of #{total} reads (#{100*kept/total.to_f})"
    end
  end
end
