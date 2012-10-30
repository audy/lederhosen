##
# MAKE TABLES
#

SEP = ','

module Lederhosen
  class CLI

    desc "otu_table",
         "create an OTU abundance matrix from USEARCH output"

    method_option :files,  :type => :string, :required => true
    method_option :output, :type => :string, :required => true

    def otu_table
      input  = options[:files]
      output = options[:output]

      ohai "generating otu table from #{input}, saving to #{output}"

      sample_cluster_count = Hash.new { |h, k| h[k] = Hash.new { h[k] = 0 } }

      # Load cluster table
      input.each do |input_file|
        File.open(input_file) do |handle|
          handle.each do |line|
            dat = parse_usearch_line(line.strip)

          end
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
        str = str.split

        # skip non hits
        return nil unless line =~ /^H/
        taxonomic_description = str[8]
        identity = line[3].to_f

        { :taxonomy => taxonomic_description, :identity => identity }
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
          name = taxonomy.match(/\[#{num}\](\w*)[;\[]/) rescue nil
          names[level] = name
        end

        names
      end

    end # no tasks

  end # class CLI
end # module Lederhosen
