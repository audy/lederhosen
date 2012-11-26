##
# MAKE TABLES
#

require 'set'

module Lederhosen
  class CLI

    desc "otu_table",
         "create an OTU abundance matrix from USEARCH prefix"

    method_option :files,  :type => :string, :required => true

    method_option :prefix, :type => :string, :required => true,
                  :banner => 'prefix prefix'

    method_option :levels, :type => :array, :required => true,
                  :banner => 'valid options: domain, kingdom, phylum, class, order, genus, or species (or all of them at once)'

    def otu_table
      input  = Dir[options[:files]]
      prefix = options[:prefix]
      levels = options[:levels].map(&:downcase)

      ohai "generating #{levels.join(', ')} table(s) from #{input.size} file(s) and saving to prefix #{prefix}."

      # sanity check
      levels.each do |level|
        fail "bad level: #{level}" unless %w{domain phylum class order family genus species kingdom}.include? level
      end

      level_sample_cluster_count = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = 0 } } }

      all_names = Hash.new { |h, k| h[k] = Set.new }

      # create a progress bar with the total number of bytes of
      # the files we're slurping up
      pbar = ProgressBar.new "loading", input.map{ |x| File.size(x) }.reduce(&:+)

      # Load cluster table
      input.each do |input_file|
        File.open(input_file) do |handle|
          handle.each do |line|

            # increase progressbar by the number of bytes in each line
            pbar.inc line.unpack('*C').size

            dat = parse_usearch_line(line.strip)

            if dat.nil? # unclassified
              levels.each { |level| level_sample_cluster_count[level][input_file]['unclassified_reads'] += 1 }
            else # classified
              levels.each do |level|
                name = dat[level] rescue nil
                all_names[level] << name
                level_sample_cluster_count[level][input_file][name] += 1
              end
            end

          end
        end
      end

      pbar.finish

      # save to csv(s)
      levels.each do |level|

        ohai "saving #{level} table"

        File.open("#{prefix}.#{level}.csv", 'w') do |handle|
          header = all_names[level].to_a.compact.sort
          handle.puts "#{level.capitalize},#{header.join(',')}"

          input.each do |sample|
            handle.print "#{sample}"
            header.each do |name|
              handle.print ",#{level_sample_cluster_count[level][sample][name]}"
            end
            handle.print "\n"
          end
        end
      end
    end


  end # class CLI
end # module Lederhosen
