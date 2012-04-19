# Lederhosen

Cluster raw Illumina 16S rRNA amplicon data to generate OTUs. Use at your own risk.

## How do I get Lederhosen?

0. Obtain & Install uclust (64-bit)
1. `sudo gem install lederhosen`

## How do I use Lederhosen?

Type `lederhosen help` for complete instructions

### 1. Trim raw reads

`$ lederhosen trim --reads-dir=reads-dir/*.txt`

### 2. Join trimmed reads

`$ lederhosen join`

### 3. Sort trimmed reads

`$ lederhosen sort`

### 4. Cluster sorted reads

`$ lederhosen cluster --identity=0.975`

### 5. Make tables & Get representative sequences

`% lederhosen otu_table --clusters=clusters.uc --output=clusters.975`

This will output a csv (`clusters.975.csv`) and a fasta (`clusters.975.fasta1) file. The fasta file can be used to identify clusters in a 16S rRNA database using BLAST or something.

### 6. Get fasta files with reads for each cluster

`% lederhosen split --clusters=clusters_97.5.txt --reads=joined.fasta --min-clst-size=100`

`--min-clst-size` is the minimum reads a cluster must have in order to for a fasta file containing its reads to be created. The reason for needing this because it is computationally prohibitive to randomly write millions of files or store all reads in memory, sort, and output non-randomly.

### 7. Figuring out what the clusters (naming them)

1. Download NCBI BLAST, or something that generates BLAST-like tables (i.e: BLAT)
2. Download a 16S rRNA database (such as [taxcollector](http://www.microgator.org/taxcollector)).
4. Generate representative reads for each cluster (that should have been done with the otu_table command).
5. BLAST those reads against your 16S rRNA database. Use `-outfmt 6` to get tabular output.
6. _et viola!_ you have identified your clusters.