##
# MAKE TABLES
#

module Lederhosen
  class CLI

    desc "otu_table",
         "create an OTU abundance matrix from USEARCH prefix"

    method_option :files,  :type => :string, :required => true

    method_option :prefix, :type => :string, :required => true,
                  :banner => 'prefix prefix'

    method_option :levels, :type => :array, :required => true,
                  :banner => 'valid options: domain, kingdom, phylum, class, order, genus, species, original (or all of them at once)'

    def otu_table
      input  = Dir[options[:files]]
      prefix = options[:prefix]
      levels = options[:levels].map(&:downcase)

      ohai "generating #{levels.join(', ')} table(s) from #{input.size} file(s) and saving to prefix #{prefix}."

      # sanity check
      levels.each do |level|
        fail "bad level: #{level}" unless %w{domain phylum class order family genus species kingdom original}.include? level
      end

      # there has to be a more efficient way of doing this
      level_sample_cluster_count =
        Hash.new do |h, k|
          h[k] = Hash.new do |h, k|
            h[k] = Hash.new(0)
          end
        end

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
                unless dat[:hit] == 'H'
                  'unclassified_reads'
                else
                  dat[level] || 'unparsed_name'
                end
              
              # remove commas from name
              name = name.tr(',', '_')

              # the next two lines are what is slow
              level_sample_cluster_count[level][input_file][name] += 1
            end

          end
        end
      end

      pbar.finish

      # get all taxonomic names at each level
      all_names = Hash.new.tap do |bar|
        level_sample_cluster_count.each_pair.map do |k, v|
          names = v.each_value.map(&:keys).flatten.uniq
          bar[k] = names
        end
      end

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
