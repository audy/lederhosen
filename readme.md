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

### 0. Pipeline

(TODO)

### 1. Trim raw reads

`$ lederhosen trim --reads-dir=reads-dir/*.txt --out-dir=trimmed`

### 2. Join trimmed reads

`$ lederhosen join --trimmed=trimmed --output=joined.fasta`

### 3. Sort trimmed reads

`$ lederhosen sort --input=joined.fasta --output=sorted.fasta`

### 4. Cluster sorted reads

`$ lederhosen cluster --identity=0.975 --input=sorted.fasta --output=clusters`

### 5. Make tables & Get representative sequences

`% lederhosen otu_table --clusters=clusters.uc --output=clusters.975 --joined=joined.fasta`

This will output a csv (`clusters.975.csv`) and a fasta (`clusters.975.fasta`) file. The fasta file can be used to identify clusters in a 16S rRNA database using BLAST or something.

### 6. Get fasta files with reads for each cluster

`% lederhosen split --clusters=clusters_97.5.txt --reads=joined.fasta --min-clst-size=100`

`--min-clst-size` is the minimum reads a cluster must have in order to for a fasta file containing its reads to be created. The reason for needing this because it is computationally prohibitive to randomly write millions of files or store all reads in memory, sort, and output non-randomly.

### 7. Figuring out what the clusters (naming them)

1. Download NCBI BLAST, or something that generates BLAST-like tables (i.e: BLAT)
2. Download a 16S rRNA database (such as [taxcollector](http://www.microgator.org/taxcollector)).
4. Generate representative reads for each cluster (that should have been done with the otu_table command).
5. BLAST those reads against your 16S rRNA database. Use `-outfmt 6` to get tabular output.
6. _et viola!_ you have identified your clusters.