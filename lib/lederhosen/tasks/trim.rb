##
# QUALITY TRIMMING
#

# This should probably be broken into its own module or command-line utility.

module Lederhosen
  class CLI

    desc "trim",
         "trim reads based on quality scores"

    method_option :reads_dir, :type => :string, :required => true
    method_option :out_dir,   :type => :string, :required => true
    method_option :pretrim,   :type => :numeric, :default => 11
    method_option :read_type, :type => :string, :default => 'qseq'
    method_option :min_length, :type => :numeric, :default => 75

    def trim
      raw_reads  = options[:reads_dir]
      out_dir    = options[:out_dir]
      pretrim    = options[:pretrim]
      read_type  = options[:read_type]
      min_length = options[:min_length]

      ohai "trimming #{File.dirname(raw_reads)} and saving to #{out_dir}"
      run "mkdir -p #{out_dir}"

      raw_reads =
        if read_type == 'qseq'
          get_grouped_qseq_files(raw_reads)
        elsif read_type == 'fastq'
          r = Dir[raw_reads].map do |x|
            [ File.basename(x, '.fastq'), x ]
          end
          Hash[r]
        end

      if raw_reads.size == 0
        ohno 'glob matches no reads'
      end

      raw_reads.map do |prefix, files|

        # get an output handle
        out = File.join(out_dir, "#{File.basename(prefix)}.fasta")

        # create the trimmed sequence generator
        trimmer =
          if read_type == 'qseq'
            Trimmer::QSEQTrimmer.new(*files)
          elsif read_type == 'fastq'
            Trimmer::InterleavedTrimmer.new(files)
          end

        # trim and write
        File.open(out, 'w') do |o|
          trimmer.each do |trimmed_record|
            o.puts trimmed_record
          end
        end # File.open

      end

    end

    no_tasks do

      # Function for grouping qseq files produced by splitting illumina
      # reads by barcode
      #
      # Filenames should look like this:
      # IL5_L_1_B_007_1.txt
      def get_grouped_qseq_files(glob='raw_reads/*.txt')
        Dir.glob(glob).group_by { |x| File.basename(x).split('_')[0..4].join('_') }
      end

    end # no_tasks

  end
end
