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
      handle = File.open(uc_file)
      uc = UCParser.new(handle)
      total_reads = 0

      if not strict
        uc.each do |result|
          unclassifieds << result.query if result.miss?
          total_reads += 1
        end

      elsif strict

        uc.each_slice(2) do |left, right|
          total_reads += 2
          if left.miss? || right.miss? # at least one is a miss
            unclassifieds << left.query
            unclassifieds << right.query
          # both are hits, check taxonomies
          else
            ta = parse_taxonomy(right.target)
            tb = parse_taxonomy(left.target)
            # inconsistent assignment or at least one is a miss
            if (ta[strict] != tb[strict])
              unclassifieds << left.query
              unclassifieds << right.query
            end
          end
        end

      end

      ohai "found #{unclassifieds.size} unclassified #{'(strict pairing)' if strict} reads."
      ohai "unclassified: #{'%0.2f' % (100*unclassifieds.size/total_reads.to_f)} %"

      handle.close

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
