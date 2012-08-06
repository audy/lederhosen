#!/bash

# An example OTU clustering pipeline
# Austin G. Davis-Richardson
# <harekrishna at gmail dot com>
# http://github.com/audy/lederhosen

set -e

raw_reads='spec/data/*.txt'
out_dir='pipeline'
taxcollector='taxcollector.fa'
min_reads=50
min_samples=10

# trim reads
lederhosen trim \
               --reads-dir=$raw_reads \
               --out-dir=$out_dir/trimmed

# join reads
lederhosen join \
               --trimmed=$out_dir/trimmed/*.fasta \
               --output=$out_dir/joined.fasta

# filter reads
lederhosen k_filter \
               --input=$out_dir/joined.fasta \
               --output=$out_dir/filtered.fasta \
               -k=10 \
               --cutoff=50

# sort
lederhosen sort \
               --input=$out_dir/filtered.fasta \
               --output=$out_dir/sorted.fasta

for i in 0.80 0.90 0.95
do
    # cluster
    lederhosen cluster \
                   --input=$out_dir/sorted.fasta \
                   --output=$out_dir/clusters_"$i".uc \
                   --identity=$i

    # filter uc file
    lederhosen uc_filter \
                   --input=$out_dir/clusters_"$i".uc \
                   --output=$out_dir/clusters_"$i".uc.filtered \
                   --reads=$min_reads \
                   --samples=$min_samples \

    # generate otu table
    lederhosen otu_table \
                   --clusters=$out_dir/clusters_"$i".uc.filtered \
                   --output=$out_dir/otus_"$i"

    # get representative reads
    lederhosen rep_reads \
                   --clusters=$out_dir/clusters_"$i".uc.filtered \
                   --joined=$out_dir/sorted.fasta \
                   --output=$out_dir/representatives_"$i".fasta

    # blast representative reads
    lederhosen name \
                   --reps=$out_dir/representatives_"$i".fasta \
                   --output=$out_dir/taxonomies_"$i".txt \
                   --database=$taxcollector
done

echo "complete!"
