<img src="https://raw.github.com/audy/lederhosen/master/logo.png" align="right">

# Lederhosen

Lederhosen is a set of tools for OTU clustering rRNA amplicons using Robert Edgar's USEARCH.

It's used to run USEARCH and create and filter tables. Unlike most of the software in Bioinformatics,
It is meant to be UNIX-y: do one thing and do it well.

Do you want to run Lederhosen on a cluster? Use `--dry-run` and feed it to your cluster's queue management system.

Lederhosen is not a pipeline but rather a set of tools broken up into tasks. Tasks are invoked by running `lederhosen TASK ...`.

Lederhosen is designed with the following "pipeline" in mind:

1. Clustering sequences to reference sequences (read: database) and/or _de novo_ OTU clustering.
  - `lederhosen cluster ...`
2. Generating tables from USEARCH output.
  - `lederhosen count_taxonomies ...`
  - `lederhosen otu_table ...`
3. Filtering tables to remove small or insignificant OTUs.
  - `lederhosen otu_filter ...`


### About

- Lederhosen is a project born out of the Triplett Lab at the University of Florida.
- Lederhosen is designed to be a fast and **simple** (~700 SLOC) tool to aid in clustering 16S rRNA amplicons sequenced
using paired and non-paired end short reads such as those produced by Illumina (GAIIx, HiSeq and MiSeq), Ion Torrent, or Roche-454.
- Lederhosen uses [Semantic Versioning](http://semver.org/), is free and open source under the
[MIT open source license](http://opensource.org/licenses/mit-license.php/).
- Except for USEARCH which requires a license, Lederhosen is available for commercial use.

### Features

- Closed/Open/Mixed OTU clustering to TaxCollector or GreenGenes via USEARCH.
- Parallel support (pipe commands into [parallel](http://savannah.gnu.org/projects/parallel/), or use your cluster's queue).
- Support for RDP, TaxCollector or GreenGenes 16S rRNA databases.
- Generation and filtering of OTU abundancy matrices.
-. Support for paired end reads (considers taxonomic assignment for both reads in a pair).

### Installation

0. Obtain & Install [USEARCH](http://www.drive5.com/) (32bit is fine for non-commercial use)
2. Get a database:
  - [TaxCollector](http://github.com/audy/taxcollector)
  - [GreenGenes](http://greengenes.lbl.gov) 16S database
  - File an [issue report](https://github.com/audy/lederhosen/issues) or pull request ;) to request support for a different database.
3. Install Lederhosen by typing:

    `sudo gem install lederhosen`
4. Check installation by typing `lederhosen`. You should see some help text.

### Need Help?

Bug me: [@heyaudy](http://twitter.com/heyaudy) (twitter)

## Tasks

Lederhosen is invoked by typing `lederhosen [TASK]`

### Trim Reads

Trimming removed. I think you should use
[Sickle](https://github.com/najoshi/sickle), or
[Trimmomatic](http://www.usadellab.org/cms/index.php?page=trimmomatic).
You can use
[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) to inspect read quality.

### Create Database

Create UDB database required by usearch from TaxCollector

```bash
lederhosen make_udb \
  --input=taxcollector.fa \
  --output=taxcollector.udb
```

(not actually required but will make batch searching a lot faster)

### Cluster Reads using USEARCH

Cluster reads using USEARCH. Output is a uc file.

```bash
lederhosen cluster \
  --input=trimmed/sequences.fasta \
  --identity=0.95 \
  --output=clusters_95.uc \
  --database=taxcollector.udb
```

The optional `--dry-run` parameter outputs the usearch command to standard out.
This is useful if you want to run usearch on a cluster.

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

Before generating OTU tables, you must generate taxonomy counts tables.

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

If you did paired-end sequencing, you can generate strict taxonomy tables that only count reads when *both pairs* have the *same*
taxonomic description at a certain taxonomic level. This is useful for leveraging the increased length of having pairs and also
acts as a sort of chimera filter. You will, however, end up using less of your reads as the level goes from domain to species.

```bash
lederhosen count_taxonomies \
  --input=clusters.uc \
  --strict=genus \
  --output=clusters_taxonomies.strict.genus.txt
```

Reads that do not have the same phylogeny at `level` will become `unclassified_reads`

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

You now will apply advanced data mining and statistical techniques to this table to make
interesting biological inferences and cure diseases.

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

- Lexi, Vinnie and Kevin for beta-testing and putting up with bugs
- The QIIME project for inspiration
- Sinbad Richardson for the Lederhosen Guy artwork

## Please Cite

Please cite this GitHub repo (https://github.com/audy/lederhosen) with the version you used (type `lederhosen version`) unless I publish a paper. Then cite that.
