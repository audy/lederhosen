require 'spec_helper'

describe String do
  it 'generate_kmers should generate kmers for a string' do
    'test'.to_kmers(2).should == ['te', 'es', 'st']
    'test'.to_kmers(3).should == ['tes', 'est']
    'test'.to_kmers(4).should == ['test']
    'test'.to_kmers(5).should == []
    'test'.to_kmers(0).should == []
  end
end