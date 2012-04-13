# Lederhosen

Cluster raw Illumina 16S rRNA amplicon data to generate OTUs.

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

`$ lederhosen cluster --idenity=0.975`

### 5. Make tables & Get representative sequences

`% lederhosen otu_table --clusters=clusters.uc --output=clusters9.75.txt`

### 6. Get fasta files with reads for each cluster

`% lederhosen split --clusters=clusters_97.5.txt --reads=joined.fasta --min-clst-size=100`

`--min-clst-size` is the minimum reads a cluster must have in order to for a fasta file containing its reads to be created. The reason for needing this because it is computationally prohibitive to randomly write millions of files or store all reads in memory, sort, and output non-randomly.