module Lederhosen

  class CLI

    desc 'cluster', 'reference-based clustering using usearch'

    method_option :input,    :type => :string,  :required => true
    method_option :database, :type => :string,  :required => true
    method_option :threads,  :type => :numeric, :default  => false
    method_option :identity, :type => :numeric, :required => true
    method_option :output,   :type => :string,  :required => true
    method_option :strand,   :type => :string,  :default => 'plus'
    method_option :dry_run,  :type => :boolean, :default => false

    def cluster
      input    = File.expand_path(options[:input])
      database = File.expand_path(options[:database])
      threads  = options[:threads]
      identity = options[:identity]
      output   = File.expand_path(options[:output])
      strand   = options[:strand]
      dry_run  = options[:dry_run]

      ohai "#{'(dry run)' if dry_run} clustering #{input} to #{database} and saving to #{output}"

      options.each_pair do |key, value|
        ohai "#{key} = #{value}"
      end

      cmd = ['usearch',
        "--usearch_local #{input}",
        "--id #{identity}",
        "--uc #{output}",
        "--db #{database}",
        "--strand #{strand}"
      ]

      # threads = False : use all threads (default)
      if threads != false
        cmd << "--threads #{threads}"
      end

      cmd = cmd.join(' ')

      unless dry_run
        run cmd
      else
        puts cmd
      end
    end
  end
end
