module Lederhosen
  class CLI
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

      # detect whether the taxonomy is one of the following
      # possible formats:
      #
      # - :taxcollector
      # - :greengenes
      # 
      def detect_taxonomy_format(taxonomy)
        # greengenes has a number as the first item in the header
        # so let's just go with that
        if taxonomy.split.first =~ /^[\d*]/
          :greengenes
        else
          :taxcollector
        end
      end

      def parse_taxonomy(taxonomy)
        format = detect_taxonomy_format(taxonomy)

        case format
        when :greengenes
          parse_taxonomy_greengenes(taxonomy)
        when :taxcollector
          parse_taxonomy_taxcollector(taxonomy)
        else
          fail 'unknown format!'
        end
      end

      def parse_taxonomy_greengenes(taxonomy)

        levels = { 'domain'  => /k__(\w*)/,
                   'kingdom' => /k__(\w*)/,
                   'phylum'  => /p__(\w*)/,
                   'class'   => /c__(\w*)/,
                   'order'   => /o__(\w*)/,
                   'family'  => /f__(\w*)/,
                   'genus'   => /g__(\w*)/,
                   'species' => /s__(\w*)/
                  }

        names = Hash.new

        levels.each_pair do |level, regexp|
          names[level] = taxonomy.match(regexp)[1] rescue nil
        end

        names['original'] = taxonomy

        names
      end

      # parse a taxonomic description using the
      # taxcollector format returning name at each level (genus, etc...)
      def parse_taxonomy_taxcollector(taxonomy)

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

        # keep original taxonomic description
        names['original'] = taxonomy

        names
      end

    end # no tasks

  end
end

