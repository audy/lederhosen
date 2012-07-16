# Lederhosen

Cluster raw Illumina 16S rRNA amplicon data to generate OTUs.

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

Trim (Illumina) reads using quality scores. Output will be a directory of fasta files.

    lederhosen trim --reads_dir=reads/* --out_dir=trimmed/

### join

Join paired reads from all samples end-to-end. This method enables the use of uclust with paired-end data. Output will be a single fasta file.

    lederhosen join --trimmed=trimmed/*.fasta --output=joined.fasta

If your reads are not paired, then you do not need to do this step. Instead, concatenate all of the trimmed reads files.

		cat trimmed/*.fasta > joined.fasta

### sort

Sort reads by length. This is a requirement for uclust's single-linkage clustering algorithim.

    lederhosen sort --input=joined.fasta --output=sorted.fasta

### k_filter

K-mer abundance noise filtering. This step is experimental and optional. It may reduce the time it takes to perform the clustering.

    lederhosen k_filter --input=joined.fasta --output=filtered.fasta --k=10 --cutoff=50

### cluster

Cluster reads using UCLUST. Output is a uc file.

    lederhosen cluster --input=sorted.fasta --identity=0.80 --output=clusters.uc

### uc_filter

Filter UC file removing singleton clusters or clusters that are only present in a few samples. This greatly reduces the noise of the data without removing many of the reads.

    lederhosen uc_filter --input=clusters.uc --output=clusters.uc.filtered --reads=50 --samples=10

### otu_table

Create an OTU abundance table where rows are samples and columns are clusters. The entries are the number of reads for that cluster in a sample.

    lederhosen otu_table --clusters=clusters.uc --output=otu_prefix.csv

### rep_reads

Get representative reads for each cluster. Output is a single fasta file.

    lederhosen rep_reads --clusters=clusters.uc --joined=joined.fasta --output=representative_reads.fasta

### split

Get all reads belonging to each cluster. Output is a directory containing a fasta file for each cluster. The fasta file contains the joined reads.

    lederhosen split --clusters=clusters.uc --reads=joined.fasta --min-clst-size=100

### name

Identify clusters in a database using the representative reads. This is a simple wrapper for BLAT. The output is a tab-delimited file similar to a BLAST output file. For this step you need to have BLAT installed and also a [TaxCollector](http://github.com/audy/taxcollector) database.

    lederhosen name --reps=representative_reads.fasta --database taxcollector.fa --output blast_like_output.txt

### add_names

Add phylogenetic classification of clusters to OTU abundance file.

	lederhosen add_names --blat=blat_output.txt --level=taxonomic_level --table=otu_file.csv --output=named_out_file.csv

Where `taxonomic_level` can be: kingdom, domain, phylum, class, order, family, genus or species. This method only works with a TaxCollector database.

### squish

Squish an OTU abundance file by column name (phylogenetic description)

	lederhosen squish --csv-file=named_out_file.csv --output=squished_named_out_file.csv
