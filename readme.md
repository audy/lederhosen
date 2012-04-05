# Lederhosen

Cluster OTUs

## How do I get Lederhosen?


### Download and install Lederhosen
```
$ git clone http://github.com/audy/lederhosen.git
$ cd lederhosen
$ sudo gem install bundler
$ sudo bundle install
```

### At this point you should be able to hose your leders:
```
$ ./lederhosen.rb

    Tasks:
    lederhosen.rb cluster      # cluster sorted joined reads
    lederhosen.rb help [TASK]  # Describe available tasks or one specific task
    lederhosen.rb join         # join trimmed reads back to back
    lederhosen.rb sort         # sort joined reads by length
    lederhosen.rb trim         # trim sequences in raw_reads/ saves to trimmed/
```

### Get some Illumina data

```
$ ls raw_reads/
ILT_L_9_B_001_1.txt ILT_L_9_B_001_3.txt
```

### Kewl! The pipeline goes like this
```
# QUALITY TRIMMING
./lederhosen.rb trim

# JOIN READS
./lederhosen.rb join

# SORT READS
./lederhosen.rb sort

# CLUSTER THEM!
./lederhosen.rb cluster --identity=0.95 --output=this_is_a_test

```