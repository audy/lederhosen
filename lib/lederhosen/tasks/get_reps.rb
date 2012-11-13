require 'set'

module Lederhosen
  class CLI
    desc 'get_reps', 'get representative reads for a uc file'

    method_option :input,    :type => :string, :required => true
    method_option :database, :type => :string, :required => true
    method_option :output,   :type => :string, :required => true

    def get_reps
      input    = options[:input]
      database = options[:database]
      output   = options[:output]

      taxa = Set.new

      ohai "getting representative database sequences from #{database} using #{input} clusters and saving to #{output}"

      # parse uc file, get list of taxa we need to get
      # full sequences for from the database
      File.open(input).each do |line|
        header = parse_usearch_line(line.strip)
        taxa << header[:original] rescue nil
      end

      ohai "found #{taxa.size} representative sequences"

      # print representative sequences from database
      output = File.open(output, 'w')
      kept = 0
      File.open(database) do |handle|
        Dna.new(handle).each do |record|
          if taxa.include? record.name
            output.puts record
            kept += 1
          end
        end
      end

      output.close

      ohai "saved #{kept} representatives"

    end
  end
end
