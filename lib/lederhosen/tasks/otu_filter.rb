module Lederhosen
  class CLI

    desc 'otu_filter', 'works like uc_filter but uses an OTU table as input'

    method_option :input, :type   =>  :string, :required => true
    method_option :output, :type  =>  :string, :required => true
    method_option :reads, :type   => :numeric, :required => true
    method_option :samples, :type => :numeric, :required => true

    def otu_filter
      input   = options[:input]
      output  = options[:output]
      reads   = options[:reads]
      min_samples = options[:samples]

      ohai "filtering otu file #{input} (reads = #{reads}, samples = #{min_samples}), saving to #{output}"

      ##
      # Iterate over otu table line by line.
      # Only print if cluster meets criteria
      #
      kept_clusters = 0
      total_reads   = 0
      kept_reads    = 0

      out = File.open(output, 'w')

      File.open(input) do |handle|
        header  = handle.gets.strip
        header  = header.split(',')
        samples = header[1..-1]

        out.puts header.join(',')

        handle.each do |line|
          line       = line.strip.split(',')
          cluster_no = line[0]
          counts     = line[1..-1].collect { |x| x.to_i }

          # should be the same as uc_filter
          if counts.reject { |x| x < reads }.length > min_samples
            out.puts line.join(',')
            kept_clusters += 1
            kept_reads += counts.inject(:+)
          end
          total_reads += counts.inject(:+)
        end
      end

      ohai "kept #{kept_reads} reads (#{kept_reads/total_reads.to_f})."
      ohai "kept #{kept_clusters} clusters."
    end

  end
end
