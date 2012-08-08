require 'spec_helper'

describe Lederhosen::Helpers do

  let (:groups) { Lederhosen::Helpers.get_grouped_qseq_files('spec/data/IL*.txt.gz') }

  it 'should have a method for grouping QSEQ files' do
    groups.length.should == 2
  end

  it 'should have a method for trimming sequences' do
    reads = groups.values.first.first
    record = Zlib::GzipReader.open(reads) do |handle|
      Dna.new(handle).first
    end
    # I should probably test with a bad read
    Lederhosen::Helpers.trim(record).length.should == 58
  end

  it 'should be able to trim pairs of qseq files, outputting fasta file' do
    reads = groups.values.first
    Lederhosen::Helpers.trim_pairs reads[0], reads[1], "#{$test_dir}/munchen_trim_test.fasta"
    # this test will break if trim parameters change
    File.readlines("#{$test_dir}/munchen_trim_test.fasta").grep(/^>/).length.should be_even
  end
end
