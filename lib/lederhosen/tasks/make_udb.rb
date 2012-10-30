module Lederhosen
  class CLI

    desc 'make_udb', 'format database for usearch'

    method_option :input,       :type => :string,  :required => true
    method_option :output,      :type => :string,  :required => true

    def make_udb
      input       = options[:input]
      output      = options[:output]
      word_length = options[:word_length]

      ohai "making udb w/ #{input}, saving as #{output}."

      cmd = ['usearch',
             "-makeudb_usearch #{input}",
             "-output #{output}"]

      cmd = cmd.join(' ')

      run cmd
    end
  end
end
