<img src="https://raw.github.com/audy/lederhosen/master/logo.png" align="right">

[![Build
Status](https://travis-ci.org/audy/lederhosen.png)](https://travis-ci.org/audy/lederhosen)

# Lederhosen

Lederhosen is a set of tools for OTU clustering rRNA amplicons using
Robert Edgar's USEARCH and is simple, robust, and fast.
Lederhosen was designed from the beginning to handle lots of data from
lots of samples, specifically from data generated by multiplexed
Illumina Hi/Mi-Seq sequencing.

No assumptions are made about the design of your experiment.
Therefore, there are no tools for read pre-processing and data analysis
or statistics. Insert reads, receive data.

Lederhosen is free and open source under the MIT license. Except for
the USEARCH license, Lederhosen is free for commercial use.

### Features

- Referenced-based OTU clustering to via USEARCH.
- Multiple Database Support (RDP, GreenGenes, TaxCollector, Silva).
- Parallel support (USEARCH, MapReduce or Compute Cluster).
- Generation and filtering of OTU abundancy matrices.

### Installation

0. Obtain & Install [USEARCH](http://www.drive5.com/).
1. Get a database:
  - [TaxCollector](http://github.com/audy/taxcollector)
  - [GreenGenes 13.5 Rep. Set](http://greengenes.secondgenome.com/downloads) 16S
    database (**recommended**)
  - File an [issue report](https://github.com/audy/lederhosen/issues) or pull request ;) to request support for a different database.
2. Install Lederhosen by typing:

    `sudo gem install lederhosen`
4. Check installation by typing `lederhosen`. You should see some help text.

### Need Help?

Tweets: [@heyaudy](http://twitter.com/heyaudy).

## Tasks

Lederhosen is invoked by typing `lederhosen [TASK]`

### Trim Reads

Trimming removed. I think you should use
[Sickle](https://github.com/najoshi/sickle), or
[Trimmomatic](http://www.usadellab.org/cms/index.php?page=trimmomatic).
You can use
[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) to inspect read quality.

### Create Database

The 16S database can optionally be in USEARCH database format (udb).
This speeds things up if you are clustering sequences in multiple FASTA
files.

```bash
lederhosen make_udb \
  --input=taxcollector.fa \
  --output=taxcollector.udb
```

### Cluster Reads using USEARCH

Cluster reads using USEARCH. Output is a uc file.

```bash
lederhosen cluster \
  --input=trimmed/sequences.fasta \
  --identity=0.95 \
  --output=clusters_95.uc \
  --database=taxcollector.udb
```

The optional `--dry-run` parameter prints the USEARCH command to
standard out. Instead of actually running the command. This is useful if
you want to run jobs in parallel and/or on a cluster.

```bash
for reads_file in reads/*.fasta;
do
    echo lederhosen cluster \
                    --input=$reads_file \
                    --identity=0.95 \
                    --output=$(basename $reads_file_ .fasta).95.uc \
                    --database=taxcollector.udb \
                    --threads 1 \
                    --dry-run
end > jobs.sh

# send jobs to queue system
cat jobs.sh | parallel -j 24 # run 24 parallel jobs
```

### Generate taxonomy counts tables

Before generating OTU tables, you must generate taxonomy counts (`.tax`) tables.

A taxonomy count table looks something like this

    # taxonomy, number_of_reads
    [0]Bacteria[1];...;[8]Akkermansia_municipalia, 28
    ...

From there, you can generate OTU abundance matrices at the different levels of classification (domain, phylum, ..., genus, species).

```bash

lederhosen count_taxonomies \
  --input=clusters.uc \
  --output=clusters_taxonomies.txt
```

### Generate OTU tables

Create an OTU abundance table where rows are samples and columns are clusters. The entries are the number of reads for that cluster in a sample.

```bash
lederhosen otu_table \
  --files=clusters_taxonomies.strict.genus.*.txt \
  --output=my_poop_samples_genus_strict.95.txt \
  --level=genus
```

This will create the file `my_poop_samples_genus_strict.95.txt` containing the clusters
as columns and the samples as rows.

If your database doesn't have taxonomic descriptions, use
`--level=original`.

### Filter OTU tables

Sometimes, clustering high-throughput reads at stringent identities can create many, small clusters.
In fact, these clusters represent the vast majority (>99%) of the created clusters but the minority (<1%>)
of the reads. In other words, 1% of the reads have 99% of the clusters.

If you want to filter out these small clusters which are composed of inseparable sequencing error or
actual biodiversity, you can do so with the `otu_filter` task.

```bash
lederhosen otu_filter \
  --input=table.csv \
  --output=filtere.csv \
  --reads=50 \
  --samples=50
```

This will remove any clusters that do not appear in at least 10 samples with at least 50 reads. The read counts
for filtered clusters will be moved to the `noise` psuedocluster.

### Get representative sequences

You can get the representative sequences for each cluster using the `get_reps` tasks.
This will extract the representative sequence from the __database__ you ran usearch with.
Make sure you use the same database that you used when running usearch.

```bash
lederhosen get_reps \
  --input=clusters.uc \
  --database=taxcollector.fa \
  --output=representatives.fasta
```

You can get the representatives from more than one cluster file using a glob:

```bash
lederhosen get_reps \
  --input=*.uc \
  --database=taxcollector.fa \
  --output=representatives.fasta
```

### Get unclassified sequences

```bash
lederhosen separate_unclassified \
  --uc-file=my_results.uc \
  --reads=reads_that_were_used_to_generate_results.fasta
  --output=unclassified_reads.fasta
```

`separate_unclassified` has support for strict pairing

```
lederhosen separate_unclassified \
  --uc-file=my_results.uc \
  --reads=reads_that_were_used_to_generate_results.fasta
  --strict=phylum
  --output=unclassified_reads.fasta
```

## Acknowledgements

- [Sinbad Richardson](http://viennapitts.com/) for the Lederhosen Guy artwork
- Lexi, and Kevin for beta-testing and putting up with bugs.
- The QIIME project for inspiration.

## Please Cite

Please cite this GitHub repo (https://github.com/audy/lederhosen) with the version you used (type `lederhosen version`) unless I publish a paper. Then cite that.
