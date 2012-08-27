module Lederhosen
  class CLI

    ##
    # PAIRED-END READ WORK-AROUND (JOIN THEM)
    #
    desc "join",
      "join paired or unpaired reads into a single file. Paired reads are joined end-to-end"

    method_option :trimmed, :type => :string, :required => true
    method_option :output,  :type => :string, :required => true
    method_option :paired,  :type => :boolean, :default => true

    def join
      trimmed = Dir[options[:trimmed]]
      output  = options[:output]
      paired  = options[:paired]

      ohai "joining #{File.dirname(trimmed.first)} saving to #{output}"

      ohno "no reads in #{trimmed}" if trimmed.length == 0

      output = File.open(output, 'w')

      pbar = ProgressBar.new "joining", trimmed.length

      trimmed.each do |fasta_file|
        pbar.inc
        records =
          begin
            Dna.new File.open(fasta_file)
          rescue
            ohai "skipping #{fasta_file} (empty?)"
            next
          end

        if paired
          output_paired_reads(records, output, fasta_file)
        else
          output_unpaired_reads(records, output, fasta_file)
        end
      end
      pbar.finish
    end

    no_tasks do
      ##
      # Output paired reads joined together
      #
      def output_paired_reads(records, output, fasta_file)
        records.each_slice(2) do |l, r|
          output.puts ">#{r.name}:split=#{r.sequence.size}:sample=#{File.basename(fasta_file, '.fasta')}"
          output.puts "#{r.sequence.reverse+l.sequence}"
        end
      end

      ##
      # Output unpaired reads
      #
      def output_unpaired_reads(records, output, fasta_file)
        records.each do |r|
          output.puts ">#{r.name}:split=na:sample=#{File.basename(fasta_file, '.fasta')}"
          output.puts r.sequence
        end
      end
    end
  end
end
