describe 'the pipeline' do

  it 'should exist' do
    `./lederhosen.rb`
    $?.success?.should be_true
  end

  it 'should trim reads' do
    `./lederhosen.rb trim`
    $?.success?.should be_true
  end

  it 'should join reads' do
    `./lederhosen.rb join`
    $?.success?.should be_true
  end

  it 'should sort reads' do
    `./lederhosen.rb sort`
    $?.success?.should be_true
  end

  it 'should cluster reads' do
    `./lederhosen.rb cluster`
    $?.success?.should be_true
  end

  it 'should build OTU abundance matrices' do
    `./lederhosen.rb otu_table`
    $?.success?.should be_true
  end

end