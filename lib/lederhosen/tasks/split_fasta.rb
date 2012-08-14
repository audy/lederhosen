##
# Split a fasta file into many fasta files with n reads
#

module Lederhosen
  class CLI

    desc 'split_fasta',
      'splits input fasta file into separate fasta files containing n reads'

    method_option :input,   :type => :string,  :required => true
    method_option :out_dir, :type => :string,  :required => true
    method_option :n,       :type => :numeric, :required => true

    def split_fasta
      input   = options[:input]
      out_dir = options[:out_dir]
      n       = options[:n].to_i

      ohai "splitting #{input} into files with #{n} reads stored in #{out_dir}"

      `mkdir -p #{out_dir}`

      File.open input do |handle|
        Dna.new(handle).each_with_index do |record, i|
          @out = File.open(File.join(out_dir, "split_#{i/n}.fasta"), 'w') if i%n == 0
          @out.puts record
        end
      end

    end
  end
end
