require 'set'

module Lederhosen

  class CLI

    desc 'separate_unclassified',
         'separate unclassified reads (with or without strict pairing)'

    method_option :uc_file, :type => :string, :required => true
    method_option :reads,   :type => :string, :required => true
    method_option :output,  :type => :string, :required => true
    method_option :strict,  :type => :string, :default => false

    def separate_unclassified
      uc_file = options[:uc_file]
      reads   = options[:reads]
      output  = options[:output]
      strict  = options[:strict]

      unclassifieds = Set.new

      UCParser.new(File.open(uc_file)) do |uc|

        if not strict
          uc.results do |result|
            unclassifieds << result.query if result.miss?
          end
        elsif strict
          uc.results.each_slice(2) do |left, right|
            if a.miss? or b.miss? # at least one is a miss
              unclassifieds << left.query
              unclassifieds << right.query
            # both are hits, check taxonomies
            else
              ta = parse_taxonomy(a.taxonomy)
              tb = parse_taxonomy(b.taxonomy)
              # they match up, count both separately
              if ta[strict] != tb[strict]
                unclassifieds << left.query
                unclassifieds << right.query
              end
            end
          end
        end

      end

      # open fasta file, output unclassified reads
      out = File.open(output, 'w')
      Dna.new(File.open(reads)).each do |record|
        if unclassifieds.include? record.name
          out.puts record
        end
      end
      out.close

    end
  end
end
