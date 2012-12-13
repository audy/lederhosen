require 'spec_helper'

describe Lederhosen::Trimmer do

  describe Lederhosen::Trimmer::PairedTrimmer do

  end

  describe Lederhosen::Trimmer::SequenceTrimmer do
    let(:sequence_trimmer) { Lederhosen::Trimmer::SequenceTrimmer.new(:cutoff => 64, :min => 20) }

    it 'can trim a record' do
    end

    it 'trims records as expected' do
      # now we need some examples
    end

  end

  describe Lederhosen::Trimmer::QSEQTrimmer do

    let(:qseq_trimmer) { Lederhosen::Trimmer::QSEQTrimmer.new 'spec/data/ILT_L_9_B_001_1.txt.gz', 'spec/data/ILT_L_9_B_001_3.txt.gz' }

    it 'can be initialized' do
      qseq_trimmer.should_not be_nil
    end

    it 'has an #each function that generates record objects' do 
      qseq_trimmer.each do |x|
        x.should be_an_instance_of Fasta
      end
    end

    it 'should create an even number of records (not output singletons)' do
      qseq_trimmer.to_a.flatten.size.should be_even
    end
  end

  describe Lederhosen::Trimmer::InterleavedTrimmer do

    let(:interleaved_trimmer) { Lederhosen::Trimmer::InterleavedTrimmer.new 'spec/data/example.fastq' }

    it 'can be initialized' do
      interleaved_trimmer.should_not be_nil
    end

    it 'has an #each function that generates record objects' do 
      interleaved_trimmer.each do |x|
        x.should be_an_instance_of Fasta
      end
    end

    it 'should create an even number of records (not output singletons)' do
      interleaved_trimmer.to_a.flatten.size.should be_even
    end
  end

end
