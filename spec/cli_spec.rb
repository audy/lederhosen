require 'spec_helper'

describe Lederhosen::CLI do

  it 'should have an executable' do
    `./bin/lederhosen`
    $?.success?.should be_true
  end

  it 'should have a version command' do
    `./bin/lederhosen version`
    $?.success?.should be_true
  end

  it 'can convert otu abundance matrices to biom format' do
    `./bin/lederhosen csv_to_biom --input=spec/data/test.csv --output=#{$test_dir}/test.biom --metadata=spec/data/test_metadata.csv`
    File.exists?(File.join($test_dir, 'test.biom')).should be_true
  end

  it 'should trim reads' do
    `./bin/lederhosen trim --reads-dir=spec/data/IL*.txt.gz --out-dir=#{$test_dir}/trimmed`
    $?.success?.should be_true
  end

  it 'can create a usearch udb using usearch' do
    `./bin/lederhosen make_udb --input #{$test_dir}/trimmed/ILT_L_9_B_001.fasta --output #{$test_dir}/test_db.udb`
    $?.success?.should be_true
  end

  it 'can cluster reads using usearch' do
    `./bin/lederhosen cluster --input #{$test_dir}/trimmed/ILT_L_9_B_001.fasta --database #{$test_dir}/test_db.udb --identity 0.95 --output #{$test_dir}/clusters.uc`
    $?.success?.should be_true
    File.exists?(File.join($test_dir, 'clusters.uc')).should be_true
  end

  it 'should build abundance matrices for each level' do
    levels = "domain phylum class order FAMILY genus Species"
    `./bin/lederhosen otu_table --files=spec/data/test.uc --prefix=#{$test_dir}/otu_table --levels=#{levels}`
    $?.success?.should be_true
  end

  it 'should filter OTU abundance matrices' do
    `./bin/lederhosen otu_filter --input=#{$test_dir}/otu_table.species.csv --output=#{$test_dir}/otu_table.filtered.csv --reads 1 --samples 1`
    $?.success?.should be_true
  end

  it 'should combine OTU abundance matrices' do
    `./bin/lederhosen join_otu_tables --input=#{$test_dir}/otu_table*.csv --output=#{$test_dir}/merged.csv`
    $?.success?.should be_true
  end

  it 'should split a fasta file into smaller fasta files (optionally gzipped)' do
    `./bin/lederhosen split_fasta --input=#{$test_dir}/trimmed/ILT_L_9_B_001.fasta --out-dir=#{$test_dir}/split/ --gzip true -n 100`
    $?.success?.should be_true
  end

  it 'should print representative sequences from uc files' do
    `./bin/lederhosen get_reps --input=#{$test_dir}/clusters.uc --database=#{$test_dir}/trimmed/ILT_L_9_B_001.fasta --output=#{$test_dir}/representatives.fasta`
  end

  it 'should create a fasta file containing representative reads for each cluster'
end
