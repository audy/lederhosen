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
      pbar = ProgressBar.new "loading", input.size

      # Load cluster table
      input.each do |input_file|
        pbar.inc
        File.open(input_file) do |handle|
          handle.each do |line|
            dat = parse_usearch_line(line.strip)
            next if dat.nil?

            levels.each do |level|
              name = dat[level] rescue nil
              all_names[level] << name
              level_sample_cluster_count[level][input_file][name] += 1
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

    no_tasks do
      # parse a line of usearch prefix
      # return a hash in the form:
      # { :taxonomy => '', :identity => 0.00, ... }
      # unless the line is not a "hit" in which case
      # the function returns nil
      def parse_usearch_line(str)

        # skip non hits
        return nil unless str =~ /^H/

        str = str.split

        taxonomic_description = str[9]
        identity = str[3].to_f

        # parse taxonomic_description
        taxonomies = parse_taxonomy(taxonomic_description)

        { :identity => identity }.merge(taxonomies)
      end

      # parse a taxonomic description using the
      # taxcollector format returning name at each level (genus, etc...)
      def parse_taxonomy(taxonomy)

        levels = { 'domain'  => 0,
                   'kingdom' => 0,
                   'phylum'  => 1,
                   'class'   => 2,
                   'order'   => 3,
                   'family'  => 4,
                   'genus'   => 5,
                   'species' => 6 }

        names = Hash.new

        levels.each_pair do |level, num|
          name = taxonomy.match(/\[#{num}\](\w*)[;\[]/)[1] rescue nil
          names[level] = name
        end

        names
      end

    end # no tasks

  end # class CLI
end # module Lederhosen
