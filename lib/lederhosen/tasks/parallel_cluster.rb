module Lederhosen
  class CLI

    desc 'parallel_cluster', 'perform reference clustering in parallel'

    method_option :identity,   :type => :numeric, :required => true
    method_option :split_size, :type => :numeric, :required => true
    method_option :lib,        :type => :string,  :required => true
    method_option :out_dir,    :type => :string,  :required => true
    method_option :reads,      :type => :string,  :required => true

    def parallel_cluster
      identity   = options[:identity]
      split_size = options[:split_size]
      lib        = options[:lib]
      out_dir    = options[:out_dir]
      reads      = options[:reads]

      empty_directory out_dir

      # split fasta file.
      # should this be a task of its own?

#      File.open(reads) do |handle|
#        records = Dna.new handle
#        n = 0
#        out = ''
#        records.each_with_index do |record, i|
#          if i%split_size == 0 || n == 0
#            n += 1
#            p n
#            out = File.open(File.join(out_dir, "split_#{n}.fasta"), 'w')
#          end
#          out.puts record
#        end
#      end

      # cluster each group in parallel
      Dir[File.join(out_dir, '*.fasta')].each do |input_file|
        CLI.new.invoke :cluster, :input => input_file, :output => "#{input_file}.uc"
        break
      end
    end
  end
end
