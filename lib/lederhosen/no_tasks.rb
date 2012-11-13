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

        # keep original taxonomic description
        names[:original] = taxonomy

        names
      end

    end # no tasks

  end
end

