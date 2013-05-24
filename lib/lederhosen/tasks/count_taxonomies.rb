module Lederhosen
  class CLI

    desc 'count_taxonomies', 'count taxonomies from a uc file, generating a csv file with: <taxonomy>,<reads>'

    method_option :input, :type => :string, :required => true
    method_option :output, :type => :string, :required => true

    def count_taxonomies
      input  = options[:input]
      output = options[:output]

      ohai "generating #{output} from #{input}"

      handle = File.open(input)
      uc = UCParser.new(handle)
      taxonomy_count = get_taxonomy_count(uc)
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

    end
  end
end
