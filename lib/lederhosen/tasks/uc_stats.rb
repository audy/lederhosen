##
# Get statistics about clusters in a UC file
#

module Lederhosen
  class CLI
    desc 'uc_stats',
      'get statistics about clusters in a UC file. for now, this only calculates the size of each cluster'

    method_option :input, :type => :string, :required => true

    def uc_stats
      input = options[:input]

      ohai "calculating statistics for #{input}"

      # TODO add more stats
      cluster_stats = Hash.new { |h, k|
        h[k] = {
          :size  => 0
        }
      }

      File.open(input) do |handle|
        handle.each do |line|
          line = line.strip.split
          type, clustr_nr = line[0], line[1]
          cluster_stats[clustr_nr][:size] += 1
        end
      end

      stat_types = cluster_stats.values.first.keys.sort

      puts "cluster,#{stat_types.join(',')}"
      cluster_stats.each do |cluster, stats|
        puts "#{cluster},#{stat_types.map { |x| stats[x] }.join(',')}"
      end
    end

  end
end
