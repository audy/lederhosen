require 'set'

module Lederhosen

  class CLI
    
    desc 'separate_unclassified', 'separate unclassified reads'
    
    method_option :uc_file, :type => :string, :required => true
    method_option :reads, :type => :string, :required => true
    method_option :output, :type => :string, :required => true

    def separate_unclassified
      uc_file = options[:uc_file]
      reads = options[:reads]
      output = options[:output]

      File.open(uc_file) do |handle|
        handle.each do |line|
          dat = parse_usearch_line(line.strip)
        end
      end
    end
  end
end