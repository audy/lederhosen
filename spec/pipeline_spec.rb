test_dir = "/tmp/lederhosen_test_#{(0...8).map{65.+(rand(25)).chr}.join}/"

`mkdir -p #{test_dir}`

describe 'the pipeline' do

  it 'should exist' do
    `./lederhosen.rb`
    $?.success?.should be_true
  end

  it 'should trim reads' do
    `./lederhosen.rb trim --reads-dir=spec/data/*.txt --out-dir=#{test_dir}/trimmed`
    $?.success?.should be_true
  end

  it 'should join reads' do
    `./lederhosen.rb join --trimmed=#{test_dir}/trimmed/*.fasta --output=#{test_dir}/joined.fasta`
    $?.success?.should be_true
  end

  it 'should sort reads' do
    `./lederhosen.rb sort --input=#{test_dir}/joined.fasta --output=#{test_dir}/sorted.fasta`
    $?.success?.should be_true
  end

  it 'should cluster reads' do
    `./lederhosen.rb cluster --identity=0.80 --reads=#{test_dir}/sorted.fasta --output=#{test_dir}/clusters.uc`
    $?.success?.should be_true
  end

  it 'should build OTU abundance matrices' do
    `./lederhosen.rb otu_table --clusters=#{test_dir}/clusters.uc --output=#{test_dir}/test_tables --joined_reads=#{test_dir}/joined.fasta`
    $?.success?.should be_true
  end

end