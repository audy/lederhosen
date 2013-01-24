
module Lederhosen
  class CLI

    attr_accessor :taxonomy_format

    no_tasks do

      # get a taxonomic description from a line of usearch (uc) output
      # return 'unclassified_reads' if the result was not a hit
      # if the result was neither a hit nor a miss (for example, a seed)
      # return nil
      # this will probably break for different versions of uc file
      # as produced by uclust or older versions of usearch
      def get_tax(s)
        dat = parse_usearch_line(s.strip)
        if dat[:type] == 'H'
          dat[:taxonomic_description].tr(',', '_')
        elsif dat[:type] == 'N'
          'unclassified_reads'
        else
          nil
        end
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
        elsif taxonomy.nil?
          raise "nil ain't no taxonomy I ever heard of!"
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

      RE_TAXCOLLECTOR = /^\[0\](.*);\[1\](.*);\[2\](.*);\[3\](.*);\[4\](.*);\[5\](.*);\[6\](.*);\[7\](.*);\[8\](.*)/
      RE_GREENGENES = /k__(.*); ?p__(.*); ?c__(.*); ?o__(.*); ?f__(.*); ?g__(.*); ?(.*);/
      RE_QIIME = /k__(.*);p__(.*);c__(.*);o__(.*);f__(.*);g__(.*);s__(.*)/

      def parse_taxonomy_qiime(taxonomy)
        levels = %w{domain phylum class order family genus species}
        match_data = taxonomy.match(RE_QIIME)
        match_data = match_data[1..-1]

        names = Hash.new
        # for some reason Hash[*levels.zip(match_data)] ain't working
        levels.zip(match_data).each { |l, n| names[l] = n }

        names['original'] = taxonomy
        names
      end

      def parse_taxonomy_greengenes(taxonomy)
        levels = %w{domain phylum class order family genus species}
        match_data = taxonomy.match(RE_GREENGENES)
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

        levels = %w{domain phylum class order family genus species strain}

        match_data =
          begin
            taxonomy.match(RE_TAXCOLLECTOR)[1..-1]
          rescue
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

