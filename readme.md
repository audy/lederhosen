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

See pipeline.sh for example usage.

## Features

- Sequence trimming (paired-end Illumina).
- K-mer filtering.
- Clustering w/ UCLUST.
- UCLUST output filtering.
- Separation of representative reads.
- Separation of all reads belonging to each cluster.
- Identification of clusters using TaxCollector.
- Generation of OTU abundancy matrices.