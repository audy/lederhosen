module Lederhosen
  class CLI

    attr_accessor :taxonomy_format

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
        taxonomies = parse_taxonomy(taxonomic_description) rescue { 'original' => str[9] }

        { :identity => identity }.merge(taxonomies)
      end

      # detect whether the taxonomy is one of the following
      # possible formats:
      #
      # - :taxcollector
      # - :greengenes
      # - :qiime (subset of greengenes)
      #
      def detect_taxonomy_format(taxonomy)
        # taxcollector taxonomy starts with a open square bracked
        if taxonomy =~ /^\[/
          :taxcollector
        elsif taxonomy =~ /^\d/
          :greengenes
        else
          :qiime
        end
      end

      def parse_taxonomy(taxonomy)
        @taxonomy_format ||= detect_taxonomy_format(taxonomy)

        case @taxonomy_format
        when :greengenes
          parse_taxonomy_greengenes(taxonomy)
        when :taxcollector
          parse_taxonomy_taxcollector(taxonomy)
        when :qiime
          parse_taxonomy_qiime(taxonomy)
        else # return original string
          { :original => taxonomy }
        end
      end

      def parse_taxonomy_qiime(taxonomy)
        levels = %w{kingdom phylum class order family genus species}
        match_data = taxonomy.match(/k__(\w*);p__(\w*);c__(\w*);o__(\w*);f__(\w*);g__(\w*);s__(\w*)/)
        match_data = match_data[1..-1]

        names = Hash.new
        # for some reason Hash[*levels.zip(match_data)] ain't working
        levels.zip(match_data).each { |l, n| names[l] = n }

        names['original'] = taxonomy
        names
      end

      def parse_taxonomy_greengenes(taxonomy)
        levels = %w{kingdom phylum class order family genus species}
        match_data = taxonomy.match(/k__(\w*); ?p__(\w*); ?c__(\w*); ?o__(\w*); ?f__(\w*); ?g__(\w*); ?(\w*);/)
        match_data = match_data[1..-1]

        names = Hash.new
        # for some reason Hash[*levels.zip(match_data)] ain't working
        levels.zip(match_data).each { |l, n| names[l] = n }

        names['original'] = taxonomy
        names
      end

      # parse a taxonomic description using the
      # taxcollector format returning name at each level (genus, etc...)
      #
      # - If the species names contains the word '_bacterium', use the strain
      # name as the species name:
      #
      #   Escherichia_bacterium -> Escherichia_bacterium_strain_X123
      #   Arcanobacterium_phocae -> Arcanobacterium_phocae (no change)
      #
      def parse_taxonomy_taxcollector(taxonomy)

        levels = %w{kingdom phylum class order family genus species strain}

        match_data =
          begin
            taxonomy.match(/\[0\](.*);\[1\](.*);\[2\](.*);\[3\](.*);\[4\](.*);\[5\](.*);\[6\](.*);\[7\](.*);\[8\](.*)/)[1..-1]
          rescue
            $stderr.puts taxonomy.inspect
            return nil
          end

        names = Hash.new
        # for some reason Hash[*levels.zip(match_data)] ain't working
        levels.zip(match_data).each { |l, n| names[l] = n }

        # check if species name contains the word 'bacterium'
        if names['species'] =~ /_bacterium/
          names['species'] = names['strain']
        end

        # keep original taxonomic description
        names['original'] = taxonomy

        names
      end

    end # no tasks

  end
end

