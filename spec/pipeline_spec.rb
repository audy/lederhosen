test_dir = "/tmp/lederhosen_test_#{(0...8).map{65.+(rand(25)).chr}.join}/"

`mkdir -p #{test_dir}`

describe 'the pipeline' do

  it 'should exist' do
    `./bin/lederhosen`
    $?.success?.should be_true
  end

  it 'should trim reads' do
    `./bin/lederhosen trim --reads-dir=spec/data/IL*.txt --out-dir=#{test_dir}/trimmed`
    $?.success?.should be_true
  end

  it 'should join reads' do
    `./bin/lederhosen join --trimmed=#{test_dir}/trimmed/*.fasta --output=#{test_dir}/joined.fasta`
    $?.success?.should be_true
  end

  it 'should sort reads' do
    `./bin/lederhosen sort --input=#{test_dir}/joined.fasta --output=#{test_dir}/sorted.fasta`
    $?.success?.should be_true
  end

  it 'should cluster reads' do
    `./bin/lederhosen cluster --identity=0.80 --input=#{test_dir}/sorted.fasta --output=#{test_dir}/clusters.uc`
    $?.success?.should be_true
  end

  it 'should build OTU abundance matrices' do
    `./bin/lederhosen otu_table --clusters=#{test_dir}/clusters.uc --output=#{test_dir}/test_tables --joined=#{test_dir}/joined.fasta`
    $?.success?.should be_true
  end

  it 'should split joined.fasta into reads for each cluster' do
    `./bin/lederhosen split --reads=#{test_dir}/joined.fasta --clusters=#{test_dir}/clusters.uc --out-dir=#{test_dir}/split --min-clst-size=1`
  end

end
