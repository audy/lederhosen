#!/bin/bash

set +e

# An example OTU clustering pipeline
# Austin G. Davis-Richardson
# <harekrishna at gmail dot com>

raw_reads='raw_reads/*.txt'
identities='0.975'
out_dir='pipeline'

# trim reads
bin/lederhosen trim --reads-dir=$raw_reads --out-dir=$out_dir/trimmed

# join reads
bin/lederhosen join --trimmed=$out_dir/trimmed/*.fasta --output=$out_dir/joined.fasta

# filter reads
bin/lederhosen filter --input=$out_dir/joined.fasta --output=$out_dir/filtered.fasta -k=10 --cutoff=50

# sort
bin/lederhosen sort --input=$out_dir/filtered.fasta --output=$out_dir/sorted.fasta

# cluster
for i in $identities
do
    bin/lederhosen cluster --input=$out_dir/sorted.fasta --output=$out_dir/clusters_"$i"_.uc --identity=$i
done

# generate otu tables
for i in $identities
do
    bin/lederhosen otu_table --clusters=$out_dir/clusters_"$i"_.uc --output=$out_dir/otus_"$i"
done

echo "complete!"