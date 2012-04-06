# Lederhosen

Cluster raw Illumina 16S rRNA amplicon data to generate OTUs.

## How do I get Lederhosen?

0. Obtain & Install uclust (64-bit)]
1. Download & extract this repo.
2. `(sudo) sh setup.sh`

Alternatively, you may use Bundler to install dependencies.

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

`% lederhosen otu_table --clusters=clusters_97.5.txt`