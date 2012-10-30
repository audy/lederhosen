##
# MAKE TABLES
#

require 'set'

module Lederhosen
  class CLI

    desc "otu_table",
         "create an OTU abundance matrix from USEARCH output"

    method_option :files,  :type => :string, :required => true
    method_option :output, :type => :string, :required => true
    method_option :level,  :type => :string, :required => true, :banner => 'valid options: domain, kingdom, phylum, class, order, genus, or species'

    def otu_table
      input  = Dir[options[:files]]
      output = options[:output]
      level  = options[:level].downcase

      ohai "generating #{level} table from #{input.size} file(s) and saving to #{output}."

      fail "bad level: #{level}" unless %w{domain phylum class order family genus species kingdom}.include? level

      sample_cluster_count = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = 0 } }

      all_names = Set.new

      # Load cluster table
      input.each do |input_file|
        File.open(input_file) do |handle|
          handle.each do |line|
            dat = parse_usearch_line(line.strip)
            next if dat.nil?
            name = dat[level] rescue ohai(dat.inspect)

            all_names << name
            sample_cluster_count[input_file][name] += 1
          end
        end
      end

      ohai "found #{all_names.size} unique taxa at #{level} level"

      # save to csv
      File.open(output, 'w') do |handle|
        header = all_names.to_a.compact.sort
        handle.puts "#{level.capitalize},#{header.join(',')}"
        samples = sample_cluster_count.keys.sort

        samples.each do |sample|
          handle.print "#{sample}"
          header.each do |name|
            handle.print ",#{sample_cluster_count[sample][name]}"
          end
          handle.print "\n"
        end
      end
    end

    no_tasks do
      # parse a line of usearch output
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
