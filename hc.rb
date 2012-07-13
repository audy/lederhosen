#!/usr/bin/env ruby

# Hierarchical clustering FTW

reads  = [ ARGV[0] ] # assumed to be sorted
out    = ARGV[1] || 'h_clustering'
ids    = [80, 90, 95]

`mkdir -p #{out}`

ids.each do |identity|

  new_reads = []

  reads.each do |r|

    # CLUSTER
    `lederhosen cluster --input=#{r} --output=#{out}/#{File.basename(r)}.#{identity}.uc --identity=0.#{identity}`

    # SPLIT
    `lederhosen split --clusters=#{out}/#{File.basename(r)}.#{identity}.uc --reads=#{r} --out-dir=#{out}/#{File.basename(r)}.#{identity}.split/`

    # SORT    
    Dir.glob("#{out}/#{File.basename(r)}.#{identity}.split/*.fasta").each { |f|
      `lederhosen sort --input=#{f} --output=#{f}.sorted`
      new_reads << "#{f}.sorted"
    }
  end

  reads = new_reads

end
