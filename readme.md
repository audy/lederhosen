# Lederhosen

Cluster raw Illumina 16S rRNA amplicon data to generate OTUs.

## How do I get Lederhosen?

1. Download & extract this repo.
2. `sh setup.sh`

## How do I use Lederhosen?

### 1. Trim raw reads

`$ ./lederhosen.rb trim --reads-dir=reads-dir/*.txt --out-dir=trimmed`

### 2. Join trimmed reads

`$ ./lederhosen.rb join --reads-dir=trimmed/*.fasta --output=joined.fasta`

### 3. Sort trimmed reads

`$ ./lederhosen.rb sort --input=joined.fasta --output=sorted.fastsa`

### 4. Cluster sorted reads

`$ ./lederhosen.rb cluster --input=sorted.fasta --identity=0.975 --output=clusters.txt`

### 5. Make tables & Get representative sequences

`% ./lederhosen.rb otu_table --clusters=clusters.txt --joined-reads=joined.fasta`