require 'set'

module Lederhosen
  class CLI
    desc 'get_reps', 'get representative reads for a uc file'

    method_option :input,    :type => :string, :required => true
    method_option :database, :type => :string, :required => true
    method_option :output,   :type => :string, :required => true

    def get_reps
      inputs   = Dir[options[:input]]
      database = File.expand_path(options[:database])
      output   = File.expand_path(options[:output])

      taxa = Set.new

      ohai "getting representative database sequences from #{database} using #{inputs.size} cluster file(s) and saving to #{output}"

      # parse uc file, get list of taxa we need to get
      # full sequences for from the database
      pbar = ProgressBar.new 'reading uc(s)', inputs.size

      inputs.each do |input|
        File.open(input) do |handle|
          pbar.inc
          handle.each do |line|
            header = parse_usearch_line(line.strip)
            taxa << header['original'] rescue nil
          end
        end
      end

      pbar.finish

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
