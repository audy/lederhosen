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

  it 'can create a usearch udb using usearch' do
    `./bin/lederhosen make_udb --input spec/data/trimmed/ILT_L_9_B_001.fasta --output #{$test_dir}/test_db.udb`
    $?.success?.should be_true
  end

  it 'can (dry run) cluster reads using usearch and output usearch cmd to stdout' do
    stdout = `./bin/lederhosen cluster --dry-run --input spec/data/trimmed/ILT_L_9_B_001.fasta --database #{$test_dir}/test_db.udb --identity 0.95 --output #{$test_dir}/clusters.uc`
    stdout.should match /^usearch/
    $?.success?.should be_true
    File.exists?(File.join($test_dir, 'clusters.uc')).should be_false
  end

  it 'can cluster reads using usearch' do
    `./bin/lederhosen cluster --input spec/data/trimmed/ILT_L_9_B_001.fasta --database #{$test_dir}/test_db.udb --identity 0.99 --output #{$test_dir}/clusters.uc`
    $?.success?.should be_true
    File.exists?(File.join($test_dir, 'clusters.uc')).should be_true
  end

  it 'can separate unclassified reads from usearch output' do
    `./bin/lederhosen separate_unclassified --uc-file=spec/data/test.uc --reads=spec/data/trimmed/ILT_L_9_B_001.fasta --output=#{$test_dir}/unclassified.fasta`
    $?.success?.should be_true
    unclassified_results = File.readlines("spec/data/test.uc")
                               .select { |x| x =~ /^N/ }
                               .size
    unclassified_reads = File.readlines("#{$test_dir}/unclassified.fasta")
                             .select { |x| x =~ /^>/ }
                             .size
  
    unclassified_results.should == unclassified_reads
  end
  
  it 'can separate unclassified reads from usearch output using strict pairing' do
    `./bin/lederhosen separate_unclassified --strict=genus --uc-file=spec/data/test.uc --reads=spec/data/trimmed/ILT_L_9_B_001.fasta --output=#{$test_dir}/unclassified.strict_genus.fasta`
    $?.success?.should be_true
    File.readlines("#{$test_dir}/unclassified.strict_genus.fasta")
      .select { |x| x =~ /^>/ }
      .size.should be_even
  end

  it 'can create taxonomy count tables' do
    `./bin/lederhosen count_taxonomies --input=spec/data/test.uc --output=#{$test_dir}/taxonomy_count.txt`
    $?.success?.should be_true
    File.exists?(File.join($test_dir, 'taxonomy_count.txt')).should be_true
  end

  it 'generates taxonomy tables w/ comma-free taxonomic descriptions' do
    File.readlines(File.join($test_dir, 'taxonomy_count.txt'))
      .map(&:strip)
      .map { |x| x.count(',') }
      .uniq
      .should == [1]
  end

  %w{domain phylum class order family genus species}.each do |level|
    it "generates taxonomy tables only counting pairs that agree at level: #{level}" do
      `./bin/lederhosen count_taxonomies --input=spec/data/test.uc --output=#{$test_dir}/taxonomy_count.strict.#{level}.txt --strict=#{level}`
      $?.success?.should be_true

      lines = File.readlines(File.join($test_dir, "taxonomy_count.strict.#{level}.txt"))

      # make sure total number of reads is even
      # requires that there should be an odd number if classification is not strict
      lines.select { |x| !(x =~ /^#/) }
           .map(&:strip)
           .map { |x| x.split(',') }
           .map(&:last)
           .map(&:to_i)
           .inject(:+).should be_even
    end
  end

  %w{domain phylum class order family genus species}.each do |level|
    it "should create OTU abundance matrices from taxonomy count tables at level: #{level}" do
      `./bin/lederhosen otu_table --files=#{$test_dir}/taxonomy_count.strict.*.txt --level=#{level} --output=#{$test_dir}/otus_genus.strict.csv`
      $?.success?.should be_true
    end
  end

  it 'should filter OTU abundance matrices' do
    # TODO
    # filtering should move filtered reads to 'unclassified_reads' so that we maintain
    # our knowledge of depth of coverage throughout
    # this makes normalization better later.
    `./bin/lederhosen otu_filter --input=#{$test_dir}/otus_genus.strict.csv --output=#{$test_dir}/otu_table.filtered.csv --reads 1 --samples 1`
    $?.success?.should be_true
  end

  it 'should split a fasta file into smaller fasta files (optionally gzipped)' do
    `./bin/lederhosen split_fasta --input=spec/data/trimmed/ILT_L_9_B_001.fasta --out-dir=#{$test_dir}/split/ --gzip true -n 100`
    $?.success?.should be_true
  end

  it 'should print representative sequences from uc files' do
    `./bin/lederhosen get_reps --input=#{$test_dir}/clusters.uc --database=spec/data/trimmed/ILT_L_9_B_001.fasta --output=#{$test_dir}/representatives.fasta`
    $?.success?.should be_true
  end
end
