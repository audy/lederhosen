require 'spec_helper'

describe Lederhosen::Trimmer do

  describe Lederhosen::Trimmer::PairedTrimmer

  describe Lederhosen::Trimmer::ProbabilityTrimmer do
    let :sequence_trimmer do
      # default cutoff should be 0.005
      Lederhosen::Trimmer::ProbabilityTrimmer.new :seq_tech => :illumina
    end

    it 'can be created' do
      sequence_trimmer.should_not be_nil
    end

    it 'trims records as expected'

  end

  describe Lederhosen::Trimmer::HuangTrimmer do

    let :sequence_trimmer do
      Lederhosen::Trimmer::HuangTrimmer.new(:offset => 64, :min => 20)
    end

    it 'trims records as expected' do

      trimmed_sizes = File.readlines('spec/data/trimmed_sizes.txt').map &:to_i

      File.open('spec/data/example.fastq') do |handle|
        records = Dna.new handle
        records.each do |record|
          trimmed_record = sequence_trimmer.trim_seq record
          trimmed_record.size.should == trimmed_sizes.shift
        end
      end
    end

  end

  describe Lederhosen::Trimmer::QSEQTrimmer do

    let :qseq_trimmer do
      Lederhosen::Trimmer::QSEQTrimmer.new 'spec/data/ILT_L_9_B_001_1.txt.gz',
                                           'spec/data/ILT_L_9_B_001_3.txt.gz'
    end

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

    let :interleaved_trimmer do
      Lederhosen::Trimmer::InterleavedTrimmer.new 'spec/data/example.fastq'
    end

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
