require 'set'

module Lederhosen
  class CLI

    desc 'otu_filter', 'works like uc_filter but uses an OTU table as input'

    method_option :input,   :type => :string,  :required => true
    method_option :output,  :type => :string,  :required => true
    method_option :reads,   :type => :numeric, :required => true
    method_option :samples, :type => :numeric, :required => true

    def otu_filter
      input       = File.expand_path(options[:input])
      output      = File.expand_path(options[:output])
      reads       = options[:reads]
      min_samples = options[:samples]

      ohai "filtering otu file #{input} (reads = #{reads}, samples = #{min_samples})"

      cluster_sample_count = Hash.new { |h, k| h[k] = Hash.new }

      ohai "loading csv file #{input}"

      # slurp up CSV file
      File.open input do |handle|
        header = handle.gets.strip.split(',')
        cluster_ids = header[1..-1]
        handle.each do |line|
          line = line.strip.split(',')
          sample_id = line[0].to_sym
          counts = line[1..-1].map(&:to_i)
          cluster_ids.zip(counts).each do |cluster, count|
            cluster_sample_count[cluster][sample_id] = count
          end
        end
      end

      ohai "filtering"

      # filter sample_cluster_count
      # todo: move filtered reads to 'unclassified_reads' classification
      filtered = cluster_sample_count.reject { |k, v| v.reject { |k, v| v < reads }.size < min_samples }

      # use functional programming they said
      # it will make your better they said
      noise = cluster_sample_count.keys - filtered.keys

      ohai "saving to #{output}"

      # save the table
      out = File.open(output, 'w')
      samples = filtered.values.map(&:keys).flatten.uniq
      clusters = filtered.keys
      out.puts "-,#{clusters.join(',')},noise"
      samples.each do |sample|
        out.print "#{sample}"
        clusters.each do |cluster|
          out.print ",#{filtered[cluster][sample]}"
        end
        noise_sum = noise.map { |n| cluster_sample_count[n][sample]}.inject(:+)
        out.print ",#{noise_sum}"
        out.print "\n"
      end
      out.close

      ohai "kept #{filtered.keys.size} clusters (#{filtered.keys.size/cluster_sample_count.size.to_f})."
      kept_reads = filtered.values.map { |x| x.values.inject(:+) }.inject(:+)
      total_reads = cluster_sample_count.values.map { |x| x.values.inject(:+) }.inject(:+)
      ohai "kept #{kept_reads}/#{total_reads} reads (#{kept_reads/total_reads.to_f})."
    end

  end
end
