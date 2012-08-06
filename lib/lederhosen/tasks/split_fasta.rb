##
# split_fasta - split a fasta file into several fasta files containing N sequences
#

module Lederhosen
  class CLI
    desc 'split_fasta',
      'split a fasta file into several fasta files containing N sequences'

    method_option :input,   :type => :string,  :required => true
    method_option :out_dir, :type => :string,  :required => true
    method_option :n,       :type => :numeric, :required => true

    def split_fasta
      input   = options[:input]
      out_dir = options[:output]
      n       = options[:n]

      File.open(input) do |handle|
        out = '' # declare the variable :)
        Dna.new(handle).each_with_index do |record, i|
          if i%n == 0 || i = 1
            ohai "#{i/n}.fasta"
            out_file = File.join(out_dir, "#{i/n}.fasta")
            out      = File.open(out_file, 'w')
          end
          out.puts record
        end
      end

    end
  end
end
