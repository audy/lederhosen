
module Lederhosen
  class CLI

    attr_accessor :taxonomy_format

    no_tasks do

      # parse a line of usearch prefix
      # return a hash in the form:
      # { :taxonomy => '', :identity => '0.00', ... }
      # unless the line is not a "hit" in which case
      # the function returns nil
      def parse_usearch_line(str)

        # from http://drive5.com/usearch/manual/ucout.html
        # 1   Record type S, H, C or N (see table below).
        # 2   Cluster number (0-based).
        # 3   Sequence length (S, N and H) or cluster size (C).
        # 4   For H records, percent identity with target.
        # 5   For H records, the strand: + or - for nucleotides, . for proteins.
        # 6   Not used, parsers should ignore this field. Included for backwards compatibility.
        # 7   Not used, parsers should ignore this field. Included for backwards compatibility.
        # 8   Compressed alignment or the symbol '=' (equals sign). The = indicates that the query is 100% identical to the target sequence (field 10).
        # 9   Label of query sequence (always present).
        # 10    Label of target sequence (H records only).

        str = str.split

        dat = {
          :type => str[0],
          :cluster_no => str[1],
          :taxonomic_description => (parse_taxonomy(taxonomic_description) rescue { 'original' => str[9] }),
          :alignment => str[7],
          :query_label => str[8],
        }

        r =
          if %w{S N H}.include? dat[:type] # hits
            { :length => str[2].to_i,
              :identity => str[3],
              :strand => str[4],
              :target_label => str[9]
            }
        elsif dat[:hit] == 'C' # clusters
          { :cluster_size => str[2].to_i }
        else
          raise Exception, "Do not understand record type #{str[0]}!"
        end

        dat.merge(r)

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

