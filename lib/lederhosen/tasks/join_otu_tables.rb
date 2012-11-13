require 'set'

module Lederhosen

  class CLI

    desc 'join_otu_tables', 'combine multiple otu tables'

    method_option :input,  :type => :string, :required => true
    method_option :output, :type => :string, :required => true

    def join_otu_tables

      input = Dir[options[:input]]
      output = File.expand_path(options[:output])

      ohai "combining #{input.size} file(s) and saving to #{output}"

      all_otu_names = Set.new
      all_samples = Set.new

      sample_name_count = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = 0 } }

      # read all of the csv files
      input.each do |input_file|
        File.open(input_file) do |handle|
          otu_names = handle.gets.strip.split(',')[1..-1]
          all_otu_names += otu_names.to_set

          handle.each do |line|
            line = line.strip.split(',')
            sample = File.basename(input_file)
            all_samples << sample
            read_counts = line[1..-1]
            otu_names.zip(read_counts) do |name, count|
              sample_name_count[sample][name] = count
            end
          end
        end
      end

      # save to csv
      File.open(output, 'w') do |handle|
        header = all_otu_names.to_a.sort
        handle.puts "-,#{header.join(',')}"

        all_samples.to_a.sort.each do |sample|
          handle.print "#{sample}"
          header.each do |name|
            handle.print ",#{sample_name_count[sample][name]}"
          end
          handle.print "\n"
        end
      end


    end
  end
end
