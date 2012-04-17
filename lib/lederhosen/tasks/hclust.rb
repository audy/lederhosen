##
# HIERARCHICAL CLUSTERING
#

module Lederhosen
  class CLI
    desc 'hclust', 'Hierarchical Clustering'

    method_option :reads,   :type => :string, :default => 'sorted.fasta'
    method_option :out_dir, :type => :string, :default => 'hclust/'

    def hclust()
      reads   = options[:reads]
      out_dir = options[:out_dir]

      `mkdir -p #{out_dir}`

      identities = ['0.80', '0.90', '0.95', '0.975']

      identities.each do |identity|
        clst_out_dir = File.join(out_dir, identity)


        cluster_and_split Dir.glob(reads),
                          :identity => identity,
                          :out_dir  => clst_out_dir

        reads = File.join(clst_out_dir, 'split', '*.fasta')
      end

    end
    
    no_tasks do
      def cluster_and_split(glob, args={})
        identity = args[:identity]
        out_dir  = args[:out_dir]

        `mkdir -p #{out_dir}/split`

        glob.each do |input|
          clst_out = File.join(out_dir, identity, '.uc')

          invoke :cluster,
                  :identity => identity,
                  :input    => input,
                  :outdir   => clst_out

          invoke :split,
                  :clusters => clst_out,
                  :reads    => input,
                  :out_dir  => File.join(args[:out_dir], 'split')

        end # glob.each        
      end # cluster_and_split
    end # no_task
    
  end
end