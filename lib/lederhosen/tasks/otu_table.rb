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
      pbar = ProgressBar.new "loading", input.size

      # Load cluster table
      input.each do |input_file|
        pbar.inc
        File.open(input_file) do |handle|
          handle.each do |line|

            dat = parse_usearch_line(line.strip)
            levels.each do |level|
              name =
                if dat.nil?
                  'unclassified_reads'
                else
                  dat[level]
                end

              name = 'unparsed_name' if name.nil?

              level_sample_cluster_count[level][input_file][name] += 1
              all_names[level] << name
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
