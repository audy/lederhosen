module Lederhosen

  # represents a usearch result
  class UResult

    attr_accessor :hit_type,
                  :cluster_no,
                  :alignment,
                  :query,
                  :target,
                  :length,
                  :identity,
                  :strand,
                  :cluster_size

    def initialize(hash)
      self.hit_type = hash[:hit_type]
      self.cluster_no = hash[:cluster_no]
      self.alignment = hash[:alignment]
      self.target = hash[:target]
      self.query = hash[:query]
      self.length = hash[:length]
      self.identity = hash[:identity]
      self.strand = hash[:strand]
      self.cluster_size = hash[:cluster_size]
    end

    def hit?
      self.hit_type == 'H'
    end

    def miss?
      self.hit_type == 'N'
    end
  end

  # class for parsing UC files, generates UResult objects
  class UCParser
    include Enumerable

    def initialize(handle)
      @handle = handle
    end

    def each(&block)
      @handle.each do |line|
        next if line =~ /^[#C]/ # skip comments and cluster summaries
        dat = parse_usearch_line(line.strip)
        result = UResult.new(dat)
        block.call(result)
      end
    end

    private

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

      str = str.split("\t")

      dat = {
        :hit_type => str[0],
        :cluster_no => str[1],
        :alignment => str[7],
        :query => str[8],
        :target => str[9],
      }

      r =
        if dat[:hit_type] =~ /[SNH]/ # hits
          { :length => str[2].to_i,
            :identity => str[3],
            :strand => str[4],
          }
      elsif dat[:hit_type] == 'C' # clusters
        { :cluster_size => str[2].to_i }
      else
        raise Exception, "Do not understand record type #{str[0]}!"
      end

      dat.merge(r)
    end
  end
end
