require 'spec_helper'

describe Lederhosen::CLI do

  it 'should have an executable' do
    `./bin/lederhosen`
    $?.success?.should be_true
  end

  it 'should have a version command' do
    `./bin/lederhosen version `.strip.should == "lederhosen-#{Lederhosen::Version::STRING}"
    $?.success?.should be_true
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
  end

  it 'should build OTU abundance matrices' do
    `./bin/lederhosen otu_table --clusters=#{$test_dir}/clusters.uc --output=#{$test_dir}/otu_table.csv`
    $?.success?.should be_true
  end

  it 'should filter OTU abundance matrices' do
    `./bin/lederhosen otu_filter --input=#{$test_dir}/otu_table.csv --output=#{$test_dir}/otu_table.filtered.csv --reads 1 --samples 1`
    $?.success?.should be_true
  end

  it 'should split a fasta file into smaller fasta files (optionally gzipped)' do
    `./bin/lederhosen split_fasta --input=#{$test_dir}/joined.fasta --out-dir=#{$test_dir}/split/ --gzip true -n 100`
    $?.success?.should be_true
  end

  it 'should create a fasta file containing representative reads for each cluster' do
    `./bin/lederhosen rep_reads --clusters=#{$test_dir}/clusters.uc --joined=#{$test_dir}/filtered.fasta --output=#{$test_dir}/representatives.fasta`
    $?.success?.should be_true
  end
end
