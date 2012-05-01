# Lederhosen

Cluster raw Illumina 16S rRNA amplicon data to generate OTUs. Use at your own risk.

## How do I get Lederhosen?

0. Obtain & Install [UCLUST](http://www.drive5.com/) (64-bit)
1. Obtain & Install [BLAT](http://genome.ucsc.edu/FAQ/FAQblat.html#blat3)
2. Get a copy of [TaxCollector](http://github.com/audy/taxcollector)
3. Install Lederhosen by typing:

    `sudo gem install lederhosen`
4. Check installation by typing `lederhosen`. You should see some help text.

## How do I use Lederhosen?

Type `lederhosen help` for complete instructions

### 1. Trim raw reads

`$ lederhosen trim --reads-dir=reads-dir/*.txt --out-dir=trimmed`

### 2. Join trimmed reads

`$ lederhosen join --trimmed=trimmed/*.fasta --output=joined.fasta`

### 3. Sort trimmed reads

`$ lederhosen sort --input=joined.fasta --output=sorted.fasta`

### 4. Cluster sorted reads

`$ lederhosen cluster --identity=0.975 --input=sorted.fasta --output=clusters`

### 5. Make OTU tables

`% lederhosen otu_table --clusters=clusters.uc --output=clusters_975.csv`

This will output a csv (`clusters.975.csv`) and a fasta (`clusters.975.fasta`) file. The fasta file can be used to identify clusters in a 16S rRNA database using BLAST or something.

### 6. Get representative reads from each cluster

`% lederhosen rep_reads --clusters=clusters.uc --joined=joined.fasta --output=representatives.fasta`

### 6. Get a fasta file containing all reads for each cluster

(time consuming and probably not necessary)

`% lederhosen split --clusters=clusters_97.5.txt --reads=joined.fasta --min-clst-size=100`

`--min-clst-size` is the minimum reads a cluster must have in order to for a fasta file containing its reads to be created. The reason for needing this because it is computationally prohibitive to randomly write millions of files or store all reads in memory, sort, and output non-randomly.

### 7. Identifying Clusters

(Still under development)

You need BLAT (in your `$PATH`) & TaxCollector.

`$ lederhosen name --reps=representatives.fasta --db=taxcollector.fa --output=output_prefix`