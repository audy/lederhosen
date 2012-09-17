##
# FINALLY, CLUSTER!
#

module Lederhosen
  class CLI

    desc "cluster",
         "cluster a fasta file using UCLUST"

    method_option :input,       :type => :string,  :required => true
    method_option :output,      :type => :string,  :required => true
    method_option :identity,    :type => :numeric, :required => true
    method_option :stepwords,   :type => :numeric, :default  => 8
    method_option :wordlen,     :type => :numeric, :default  => 8
    method_option :maxaccepts,  :type => :numeric, :default  => 1
    method_option :maxrejects,  :type => :numeric, :default  => 8
    method_option :lib,         :type => :string
    method_option :libonly,     :type => :boolean, :default  => false

    def cluster
      identity   = options[:identity]
      output     = options[:output]
      input      = options[:input]
      stepwords  = options[:stepwords]
      maxaccepts = options[:maxaccepts]
      maxrejects = options[:maxrejects]
      wordlen    = options[:wordlen]
      lib        = options[:lib]
      libonly    = options[:libonly]

      ohai "clustering #{input}, saving to #{output}"

      options.each_pair do |key, value|
        ohai "#{key} = #{value}"
      end

      cmd = [
        'uclust',
        "--input #{input}",
        "--uc #{output}",
        "--id #{identity}",
        "--stepwords #{stepwords}",
        "--maxaccepts #{maxaccepts}",
        "--maxrejects #{maxrejects}",
        "--w #{wordlen}"
      ]

      cmd << "--lib #{lib}" unless lib.nil?
      cmd << "--libonly" if libonly == true

      cmd = cmd.join(' ')

      @shell.mute { run cmd }
    end

  end
end
