##
# HIERARCHICAL CLUSTERING FTW
#

module Lederhosen
  class CLI

    desc "h_cluster",
         "--input=sorted.fasta --identity=0.80 --output=clusters.uc --identities=0.80 0.90 0.95"

    method_option :input,      :type => :string, :required => true
    method_option :out_dir,    :type => :string, :required => true
    method_option :identities, :type => :array,  :required => true

    def h_cluster
      out_dir    = options[:out_dir]
      input      = options[:input]
      identities = options[:identities].map(&:to_f).sort

      `mkdir -p #{out_dir}`

      # initial clustering
      i = identities.shift
      clusters = File.join(out_dir, "clusters_#{i}.uc")
      clusters_filtered = File.join(out_dir, "clusters_#{i}.uc.filtered")

      # cluster
      invoke :cluster, [], { :input => input, :output => clusters, :identity => i }

      # filter
      invoke :uc_filter, [], { :input => clusters, :output => clusters_filtered }

      # get reads for each cluster
      invoke :split, [], { :clusters => clusters_filtered, :reads => input }
      
      [t1, t2, t3].map(&:call)
    end

  end
end