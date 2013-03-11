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

      # make one pass finding which OTUs to keep
      # create mask that maps which columns correspond to good OTUs
      # pass over table again printing only those columns

      seen = Hash.new { |h, k| h[k] = 0 }

      otu_order = []

      pbar = ProgressBar.new 'counting', File.size(input)
      total_reads = 0

      File.open(input) do |handle|
        header = handle.gets.strip.split(',')
        header.each { |x| otu_order << x }

        handle.each do |line|
          pbar.set handle.pos
          line = line.strip.split(',')
          sample_name = line[0]
          abunds = line[1..-1].map &:to_i
          otu_order.zip(abunds) do |o, a|
            total_reads += a
            seen[o] += 1 if a >= reads
          end
        end
      end

      pbar.finish

      mask = otu_order.map { |x| seen[x] >= min_samples }
      ohai "found #{otu_order.size} otus, keeping #{mask.reject { |x| x }.size}"

      output = File.open(output, 'w')

      pbar = ProgressBar.new 'writing', File.size(input)
      filtered_reads = 0
      File.open(input) do |handle|
        header = handle.gets.strip.split(',')
        header = header.zip(mask).map { |k, m| k if m }.compact
        output.puts header.join(',')

        handle.each do |line|
          pbar.set handle.pos
          line = line.strip.split(',')

          sample_name = line[0]
          counts = line[1..-1]

          counts = counts.zip(mask).map { |h, k| h.to_i if k }.compact
          filtered_reads += counts.inject(:+)

          output.puts "#{sample_name},#{counts.join(',')}"

        end
      end

      pbar.finish

      ohai "kept #{total_reads}/#{filtered_reads} reads (#{100*filtered_reads/total_reads.to_f}%)"

      output.close

    end

  end
end
