module Lederhosen
  class CLI

    ##
    # PAIRED-END READ WORK-AROUND (JOIN THEM)
    #
    desc "join reads end-to-end",
         "--trimmed=trimmed/*.fasta --output=joined.fasta"

    method_option :trimmed, :type => :string, :default => 'trimmed/*.fasta'
    method_option :output,  :type => :string, :default => 'joined.fasta'

    def join

      trimmed = Dir[options[:trimmed]]
      output = options[:output]

      fail "no reads in #{trimmed}" if trimmed.length == 0

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

        records.each_slice(2) do |r, l|
          output.puts ">#{r.name}:#{File.basename(fasta_file, '.fasta')}\n#{r.sequence.reverse+l.sequence}"
        end
      end
      pbar.finish
    end

  end
end