##
# FILTER UC FILE BY MIN SAMPLES
#
require 'set'

module Lederhosen
  class CLI

    desc "uc_filter",
         "filter UCLUST output to remove small, infrequent clusters"

    method_option :input,    :type => :string,  :required => true
    method_option :output,   :type => :string,  :required => true
    method_option :reads,    :type => :numeric, :required => true
    method_option :samples,  :type => :numeric, :required => true

    def uc_filter
      input   = options[:input]
      output  = options[:output]
      reads   = options[:reads].to_i
      samples = options[:samples].to_i

      ohai "filtering #{input} to #{output}, reads = #{reads} & samples = #{samples}"

      # load UC file
      clstr_info   = Helpers.load_uc_file input
      clstr_counts = clstr_info[:clstr_counts] # clstr_counts[:clstr][sample.to_i] = reads

      # filter
      survivors = clstr_counts.reject do |a, b|
        b.reject{ |i, j| j < reads }.length < samples
      end

      surviving_clusters = survivors.keys.to_set

      # print filtered uc file
      out = File.open(output, 'w')
      kept, total = 1, 0
      lines = `wc -l #{input}`.split.first.to_i
      pbar = ProgressBar.new 'saving', lines
      File.open(input) do |handle|
        handle.each do |line|
          pbar.inc
          if line =~ /^#/
            out.print line
            next
          end

          total += 1

          if surviving_clusters.include? line.split[1].to_i
            out.print line
            kept += 1
          end
        end
      end
      pbar.finish
      out.close
      ohai "Survivors"
      ohai "clusters: #{surviving_clusters.length}/#{clstr_counts.keys.length} = #{100*surviving_clusters.length/clstr_counts.keys.length.to_f}%"
      ohai "reads:    #{kept}/#{total} = #{100*kept/total.to_f}%"
    end
  end

end
