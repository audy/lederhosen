module Lederhosen
  class CLI

    desc 'count_taxonomies', 'count taxonomies from a uc file, generating a csv file with: <taxonomy>,<reads>'

    method_option :input, :type => :string, :required => true
    method_option :output, :type => :string, :required => true
    method_option :strict, :type => :string, :default => false,
                  :banner => '<level> only count reads where both taxonomies are in agreement at <level>'

    def count_taxonomies
      input  = options[:input]
      output = options[:output]
      strict = options[:strict]

      ohai "generating #{output} from #{input}"

      handle = File.open(input)
      uc = UCParser.new(handle)

      taxonomy_count =
        if not strict
          get_taxonomy_count(uc)
        elsif strict
          get_strict_taxonomy_count(uc, strict)
        end

      handle.close

      out = File.open(output, 'w')
      out.puts '# taxonomy, number_of_reads'
      taxonomy_count.each_pair do |taxonomy, count|
        out.puts "#{taxonomy.tr(',','_')},#{count}"
      end
      out.close

    end

    no_tasks do
      # returns Hash of taxonomy => number_of_reads
      def get_taxonomy_count(uc)
        taxonomy_count = Hash.new { |h, k| h[k] = 0 }
        uc.each do |result|
          if result.hit?
            taxonomy_count[result.target] += 1
          else
            taxonomy_count['unclassified_reads'] += 1
          end
        end
        taxonomy_count
      end

      # returns Hash of taxonomy => number_of_reads
      # if a pair of reads do not agree at a taxonomic level,
      # or if at least one is unclassified, bot reads are counted
      # as unclassified_reads
      def get_strict_taxonomy_count(uc, level)
        taxonomy_count = Hash.new { |h, k| h[k] = 0 }
        # TODO: I'm making a block for results because I don't know how to
        # make results return an Enumerator when not given a block
        uc.each_slice(2) do |left, right|
          if left.miss? or right.miss? # at least one is a miss
            taxonomy_count['unclassified_reads'] += 2
          # both are hits, check taxonomies
          else
            ta = parse_taxonomy(left.target)
            tb = parse_taxonomy(right.target)
            # they match up, count both separately
            if ta[level] == tb[level]
              taxonomy_count[left.target] += 1
              taxonomy_count[right.target] += 1
            # they don't match up, count as unclassified
            else
              taxonomy_count['unclassified_reads'] += 2
            end
          end
        end # results.each_slice
        taxonomy_count
      end
      
    end
  end
end
