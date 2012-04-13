require 'spec_helper'

describe Helpers do
  
  let (:groups) { Helpers.get_grouped_qseq_files('spec/data/*.txt') }
  
  it 'should have a method for grouping QSEQ files' do
    groups.length.should == 2
  end

  it 'should have a method for trimming sequences' do
    reads = groups.values.first.first
    record = File.open(reads) do |handle|
      Dna.new(handle).first
    end
    # I should probably test with a bad read
    Helpers.trim(record).length.should == 79
  end

  it 'should be able to trim pairs of qseq files, outputting fasta file' do
    reads = groups.values.first
    Helpers.trim_pairs reads[0], reads[1], '/tmp/munchen_trim_test.fasta'
    # this test will break if trim parameters change
    File.read('/tmp/munchen_trim_test.fasta').grep(/^>/).length.should be_even
  end
end