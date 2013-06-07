module Lederhosen
  class CLI

    desc 'make_udb', 'format database for usearch'

    method_option :input,  :type => :string, :required => true
    method_option :output, :type => :string, :required => true
    method_option :word_length, :type => :numeric, :default => 64
    method_option :db_step, :type => :numeric, :default => 4

    def make_udb
      input       = options[:input]
      output      = options[:output]
      word_length = options[:word_length]
      db_step     = options[:db_step]

      ohai "making udb w/ #{input}, saving as #{output}."

      cmd = ['usearch',
             "-makeudb_usearch #{input}",
             "-output #{output}",
             "-wordlength #{word_length}",
             "-dbstep #{db_step}",
            ]

      cmd = cmd.join(' ')

      run cmd
    end
  end
end
