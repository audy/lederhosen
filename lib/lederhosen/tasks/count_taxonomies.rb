module Lederhosen
  class CLI
    
    desc 'count_taxonomies', 'count taxonomies'
    
    method_option :input, :type => :string, :required => true
    method_option :output, :type => :string, :required => true
    method_option :strict, :type => :string, :default => false,
                  :banner => '<level> only count reads where both taxonomies are in agreement at <level>'
    
    def count_taxonomies
      input  = options[:input]
      output = options[:output]
      strict = options[:strict]

      ohai "generating #{output} from #{input}"

      taxonomy_count = Hash.new { |h, k| h[k] = 0 }

      File.open(input) do |handle|
        handle.each do |line|
          dat = parse_usearch_line(line.strip)

          taxonomy =
            if dat[:type] == 'H'
              dat[:taxonomic_description]["original"].tr(',','_') # remove commas!
            elsif dat[:type] == 'N'
              'unclassified_reads'
            else
              nil
            end

          taxonomy_count[taxonomy] += 1

        end
      end

      out = File.open(output, 'w')
      out.puts "taxonomy,number_of_reads"
      taxonomy_count.each_pair do |taxonomy, count|
        out.puts "#{taxonomy},#{count}"
      end
      out.close

    end
  end
end