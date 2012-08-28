##
# Split a fasta file into many fasta files with n reads
#

require 'zlib'

module Lederhosen
  class CLI

    desc 'split_fasta',
      'splits input fasta file into separate fasta files containing n reads'

    method_option :input,   :type => :string,  :required => true
    method_option :out_dir, :type => :string,  :required => true
    method_option :n,       :type => :numeric, :required => true
    method_option :gzip,    :type => :boolean, :default  => false

    def split_fasta
      input   = options[:input]
      out_dir = options[:out_dir]
      n       = options[:n].to_i
      gzip    = options[:gzip]

      ohai "splitting #{input} into files with #{n} reads stored in #{out_dir}"
      ohai "using gzip" if gzip

      `mkdir -p #{out_dir}`

      File.open input do |handle|
        pbar = ProgressBar.new 'splitting', File.size(handle)
        Dna.new(handle).each_with_index do |record, i|
          pbar.set handle.pos
          # I have to use a class variable here because
          # if I don't the variable gets set to nil after
          # after each iteration.
          @out =
            if i%n == 0 # start a new file
              # GzipWriter must be closed explicitly
              # this raises an exception this first time
              @out.close rescue nil

              # create an IO object depending on whether or
              # not the user wants to use gzip
              if gzip
                Zlib::GzipWriter.open(File.join(out_dir, "split_#{i/n}.fasta.gz"))
              else
                File.open(File.join(out_dir, "split_#{i/n}.fasta"), 'w')
              end
            else # keep using current handle
              @out
            end
          @out.puts record
        end
        pbar.finish
        @out.close
      end

      ohai "created #{Dir[File.join(out_dir, '*')].size} files"
    end
  end
end
