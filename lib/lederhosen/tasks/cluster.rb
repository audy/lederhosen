module Lederhosen

  class CLI

    desc 'cluster', 'reference-based clustering using usearch'

    method_option :input,    :type => :string,  :required => true
    method_option :database, :type => :string,  :required => true
    method_option :threads,  :type => :numeric, :default  => 0
    method_option :identity, :type => :numeric, :required => true
    method_option :output,   :type => :string,  :required => true
    method_option :strand,   :type => :string,  :default => 'plus'

    def cluster
      input    = options[:input]
      database = options[:database]
      threads  = options[:threads]
      identity = options[:identity]
      output   = options[:output]
      strand   = options[:strand]

      ohai "clustering #{input} to #{database} and saving to #{output}"

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

      # threads = 0 : use all threads (default)
      if threads != 0
        cmd << "--threads #{threads}"
      end

      cmd = cmd.join(' ')

      run cmd
    end
  end
end
