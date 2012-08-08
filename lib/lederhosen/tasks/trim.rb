##
# QUALITY TRIMMING
#

module Lederhosen
  class CLI

    desc "trim",
         "trim reads based on quality scores"

    method_option :reads_dir, :type => :string, :required => true
    method_option :out_dir,   :type => :string, :required => true

    def trim
      raw_reads = options[:reads_dir]
      out_dir   = options[:out_dir]

      ohai "trimming #{File.dirname(raw_reads)} and saving to #{out_dir}"

      run "mkdir -p #{out_dir}"

      raw_reads = Helpers.get_grouped_qseq_files raw_reads

      ohai "found #{raw_reads.length} pairs of reads"

      pbar = ProgressBar.new "trimming", raw_reads.length
      raw_reads.each do |a|
        pbar.inc
        out = File.join(out_dir, "#{File.basename(a[0])}.fasta")
        # TODO get total and trimmed
        total, trimmed = Helpers.trim_pairs a[1][0], a[1][1], out, :min_length => 70
      end
      pbar.finish

    end
  end
end
