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

      File.open(input) do |handle|
        handle.each do |line|

          taxonomy = get_tax(line.strip)
          
          unless strict
            taxonomy_count[taxonomy] += 1
          else
            next_tax = get_tax(handle.gets.strip)
            a, b = parse_taxonomy(taxonomy), parse_taxonomy(next_tax)
            unless ([a, b].include? nil) || ([a, b].include? 'unclassified_reads')
              if a[strict] == b[strict]
                taxonomy_count[taxonomy] += 2
              else
                taxonomy_count['unclassified_reads'] += 2
              end
            else
              taxonomy_count['unclassified_reads'] += 2
            end
          end

        end
      end

      out = File.open(output, 'w')
      out.puts '# taxonomy, number_of_reads'
      taxonomy_count.each_pair do |taxonomy, count|
        out.puts "#{taxonomy},#{count}"
      end
      out.close

    end
  end
end