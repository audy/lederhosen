#!/bin/bash

set -e
set -x

# Hierarchical OTU clustering
# Austin G. Davis-Richardson
# <harekrishna at gmail dot com>
# http://github.com/audy/lederhosen

reads='sorted.fasta'
out='h_clustering'

mkdir -p $out

# initial clustering at 80%
lederhosen cluster --input=$reads --output=$out/clusters_0.80.uc --identity=0.80

# filter UC file
lederhosen uc_filter --input=$out/clusters_0.80.uc --output=$out/clusters_0.80.uc.filtered --reads=1 --samples=1

# get reads for each cluster
mkdir -p $out/split_80
lederhosen split --clusters=$out/clusters_0.80.uc.filtered --reads=$reads --out-dir=$out/split_80/

# now cluster each of those at 90%
for fasta in $out/split_80/*.fasta
do

  # sort (awww, do I really have to do this again?)
  lederhosen sort --input=$fasta --output=$fasta.sorted

  # cluster
  lederhosen cluster --input=$fasta.sorted --output=$fasta.uc --identity=0.90

  # split
  split=$out/split_80.90_$(basename $fasta .fasta)
  lederhosen split --clusters=$fasta.uc --reads=$fasta --out-dir=$split
done

# Do it again at 95%
for fasta in $out/split_80/split_*_90.fasta/*.fasta
do
  # cluster
  lederhosen cluster --input=$fasta --output=$fasta.uc --identity=90

  # split
  split=$outdir/80.90.$fasta.fasta
  mkdir -p $split
  lederhosen split --clusters=$fasta.uc --reads=$input --out-dir=$split
done
