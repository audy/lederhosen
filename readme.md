# Lederhosen

Cluster raw Illumina 16S rRNA amplicon data to generate OTUs. Use at your own risk.

## How do I get Lederhosen?

0. Obtain & Install [UCLUST](http://www.drive5.com/) (64-bit)
1. Obtain & Install [BLAT](http://genome.ucsc.edu/FAQ/FAQblat.html#blat3)
2. Get a copy of [TaxCollector](http://github.com/audy/taxcollector)
3. Install Lederhosen by typing:

    `sudo gem install lederhosen`
4. Check installation by typing `lederhosen`. You should see some help text.

## Features

- Sequence trimming (paired-end Illumina).
- K-mer filtering.
- Clustering w/ UCLUST.
- UCLUST output filtering.
- Separation of representative reads.
- Separation of all reads belonging to each cluster.
- Identification of clusters using TaxCollector.
- Generation of OTU abundancy matrices.

## How do I use Lederhosen?

Lederhosen is just a convenient wrapper for UCLUST and BLAT with some scripts for quality filtering, de-noising of data as well as creation of nice tables. It is similar to QIIME but meant for paired-end Illumina data rather than single-end 454. The basic lederhosen pipeline consists of: trimming, joining, sorting, filtering, clustering, more filtering, and output generation (OTU tables, representative reads, reads by cluster, and taxonomic descriptions for clusters). See the example pipeline in `pipeline.sh`.

## Tasks

Lederhosen is invoked by typing `lederhosen [TASK]`

### trim

Trim (Illumina) reads using quality scores

    lederhosen trim --reads_dir=reads/* --out_dir=trimmed.fasta

### join

Join reads end-to-end

    lederhosen join --trimmed=trimmed/*.fasta --output=joined.fasta

### sort

Sort reads by length

    lederhosen sort --input=joined.fasta --output=sorted.fasta

### k_filter

K-mer abundance noise filtering

    lederhosen k_filter --input=joined.fasta --output=filtered.fasta --k=10 --cutoff=50

### cluster

Cluster reads using UCLUST

    lederhosen cluster --input=sorted.fasta --identity=0.80 --output=clusters.uc

### uc_filter

Filter UC file (more noise filtering)

    lederhosen uc_filter --input=clusters.uc --output=clusters.uc.filtered --reads=50 --samples=10

### otu_table

Create an OTU table

    lederhosen otu_table --clusters=clusters.uc --output=otu_prefix

### rep_reads

Get representative reads for each cluster

    lederhosen rep_reads --clusters=clusters.uc --joined=joined.fasta --output=representative_reads.fasta

### split

Get all reads belonging to each cluster

    lederhosen split --clusters=clusters.uc --reads=joined.fasta --min-clst-size=100

### name

    lederhosen name --reps=representative_reads.fasta --database taxcollector.fa --output blast_like_output.txt

