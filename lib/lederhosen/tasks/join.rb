module Lederhosen
  class CLI

    ##
    # PAIRED-END READ WORK-AROUND (JOIN THEM)
    #
    desc "join",
         "join trimmed reads into a single file"

    method_option :trimmed, :type => :string, :required => true
    method_option :output,  :type => :string, :required => true

    def join
      trimmed = Dir[options[:trimmed]]
      output  = options[:output]

      ohai "joining #{File.dirname(trimmed.first)} saving to #{output}"

      ohno "no reads in #{trimmed}" if trimmed.length == 0

      output = File.open(output, 'w')

      pbar = ProgressBar.new "joining", trimmed.length

      trimmed.each do |fasta_file|
        pbar.inc

        begin
          records = Dna.new File.open(fasta_file)
        rescue
          ohai "skipping #{fasta_file} (empty?)"
          next
        end

        records.each_slice(2) do |l, r|
          output.puts ">#{r.name}:split=#{r.sequence.size}:sample=#{File.basename(fasta_file, '.fasta')}\n#{r.sequence.reverse+l.sequence}"
        end
      end
      pbar.finish
    end

  end
end
