<img src="http://d.pr/i/26Js+#.png" align="right">

# Lederhosen

Lederhosen is a set of tools for OTU clustering rRNA amplicons using Robert Edgar's USEARCH.

It handles quality control of raw sequence data, running USEARCH, and creating and filtering tables.

Lederhosen is not a pipeline but rather a set of tools broken up into tasks. Tasks are invoked by running `lederhosen TASK ...`.

Lederhosen is designed with the following "pipeline" in mind:

1. Quality control of sequence data.
2. Clustering sequences to centroid or reference sequences.
3. Generating tables from USEARCH output.
4. Filtering tables to remove small or insignificant OTUs.

### Why not QIIME?

QIIME is great but imagine for a moment, if you will, a world where there was only one web browser.

### About

- Lederhosen is a project born out of the Triplett Lab at the University of Florida.
- Lederhosen is designed to be a fast and simple method of clustering 16S rRNA amplicons sequenced
using paired and non-paired end short reads such as those produced by Illumina (GAIIx, HiSeq and MiSeq).
- Lederhosen uses [Semantic Versioning](http://semver.org/).
- Lederhosen is free and open source under the [MIT open source license](http://opensource.org/licenses/mit-license.php/).
- Except for USEARCH which requires a license, Lederhosen is available for commercial use.

### Features

- Sequence trimming (paired-end Illumina).
- Parallel, referenced-based clustering to TaxCollector using USEARCH
- Generation and filtering of OTU abundancy matrices.

### Installation

0. Obtain & Install [USEARCH](http://www.drive5.com/) (32bit is fine for non-commercial use)
2. Get a copy of [TaxCollector](http://github.com/audy/taxcollector) or [GreenGenes](http://greengenes.lbl.gov) 16S database
3. Install Lederhosen by typing:

    `sudo gem install lederhosen`
4. Check installation by typing `lederhosen`. You should see some help text.

## Tasks

Lederhosen is invoked by typing `lederhosen [TASK]`

### Trim Reads

Trim (Illumina, QSEQ format) reads using quality scores. Output will be a directory of fasta files. Reads can optionally be gzipped.

    lederhosen trim --reads_dir=reads/*.txt --out_dir=trimmed/

The trimming process will reverse complement the "right" pair so that both reads are in the forward orientation.

You can also trim interleaved, paired-end FASTQ files:

    lederhosen trim --reads_dir=reads/*.fastq --out_dir=trimmed/ read-type='fastq'

(WARNING: by default, Lederhosen trims off the first 11 nucleotides. This was to remain backwards-compatibility with an experiment-specific version. To disable use `--pretrim 0`)

### Create Database

Create UDB database required by usearch from TaxCollector

```bash
lederhosen make_udb \
  --input=taxcollector.fa \
  --output=taxcollector.udb
```

### Cluster Reads using USEARCH

Cluster reads using USEARCH. Output is a uc file.

```bash
lederhosen cluster \
  --input=trimmed/*.fasta \
  --identity=0.95 \
  --output=clusters_95.uc \
  --database=taxcollector.udb
```

The optional `--dry-run` parameter outputs the usearch command to standard out. This is useful if you want to run usearch on a cluster.

### Generate OTU table(s)

Create an OTU abundance table where rows are samples and columns are clusters. The entries are the number of reads for that cluster in a sample.

```bash
lederhosen otu_table \
  --files=clusters_95.uc \
  --prefix=otu_table \
  --levels=domain phylum class order family genus species
```

This will create the files:

    otu_table.domain.csv, ..., otu_table.species.csv

### Get representative sequences

You can get the representative sequences for each cluster using the `get_reps` tasks. This will extract the representative sequence from
the __database__ you ran usearch with. Make sure you use the same database that you used when running usearch.

    lederhosen get_reps --input=clusters.uc --database=taxcollector.fa --output=representatives.fasta

You can get the representatives from more than one cluster file using a glob:

    lederhosen get_reps --input=*.uc --database=taxcollector.fa --output=representatives.fasta
