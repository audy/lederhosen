require 'spec_helper'

describe Lederhosen::CLI do

  it 'should have an executable' do
    `./bin/lederhosen`
    $?.success?.should be_true
  end

  it 'should have a version command' do
    `./bin/lederhosen version `.strip.should == "lederhosen-#{Lederhosen::Version::STRING}"
  end

  it 'should trim reads' do
    `./bin/lederhosen trim --reads-dir=spec/data/IL*.txt.gz --out-dir=#{$test_dir}/trimmed`
    $?.success?.should be_true
  end

  it 'should join reads' do
    `./bin/lederhosen join --trimmed=#{$test_dir}/trimmed/*.fasta --output=#{$test_dir}/joined.fasta`
    $?.success?.should be_true
  end

  it 'should sort reads' do
    `./bin/lederhosen sort --input=#{$test_dir}/joined.fasta --output=#{$test_dir}/sorted.fasta`
    $?.success?.should be_true
  end

  it 'should k_filter reads' do
    `./bin/lederhosen k_filter --input=#{$test_dir}/sorted.fasta --output=#{$test_dir}/filtered.fasta -k=15 --cutoff 1`
    $?.success?.should be_true
  end

  it 'should cluster reads' do
    `./bin/lederhosen cluster --identity=0.80 --input=#{$test_dir}/filtered.fasta --output=#{$test_dir}/clusters.uc`
    $?.success?.should be_true
  end

  it 'should build OTU abundance matrices' do
    `./bin/lederhosen otu_table --clusters=#{$test_dir}/clusters.uc --output=#{$test_dir}/otu_table.csv`
    $?.success?.should be_true
  end

  it 'should filter OTU abundance matrices' do
    `./bin/lederhosen otu_filter --input=#{$test_dir}/otu_table.csv --output=#{$test_dir}/otu_table.filtered.csv --reads 1 --samples 1`
  end

  it 'should split a fasta file into smaller fasta files (optionally gzipped)' do
    `./bin/lederhosen split_fasta --input=#{$test_dir}/joined.fasta --out-dir=#{$test_dir}/split/ --gzip true -n 100`
    $?.success?.should be_true
  end

  it 'should split joined.fasta into reads for each cluster' do
    `./bin/lederhosen split --reads=#{$test_dir}/joined.fasta --clusters=#{$test_dir}/clusters.uc --out-dir=#{$test_dir}/split --min-clst-size=1`
  end

  it 'should create a fasta file containing representative reads for each cluster' do
    `./bin/lederhosen rep_reads --clusters=#{$test_dir}/clusters.uc --joined=#{$test_dir}/filtered.fasta --output=#{$test_dir}/representatives.fasta`
    $?.success?.should be_true
  end

  # Need a taxcollector database for this one.
  it 'should identify clusters given a taxcollector database'

  it 'should add names to otu abundance matrix given blat output' do
    levels = %w{kingdom domain phylum class order genus speces}
    # Ruby 1.9 vs Ruby 1.8
    level = levels.sample rescue levels.choice
    `./bin/lederhosen add_names --table=spec/data/otus.csv --blat=spec/data/blat.txt --level=#{level} --output=#{$test_dir}/named_otus.csv`
    $?.success?.should be_true
  end

  it 'should squish otu abundance matrix by same name' do
    `./bin/lederhosen squish --csv-file=#{$test_dir}/named_otus.csv --output=#{$test_dir}/squished.csv`
    $?.success?.should be_true
  end
end
