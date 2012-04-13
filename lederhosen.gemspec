# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'lib/version'

Gem::Specification.new do |s|
  s.name        = 'lederhosen'
  s.version     = Lederhosen::VERSION
  s.authors     = ["Austin G. Davis-Richardson"]
  s.email       = ["harekrishna@gmail.com"]
  s.homepage    = "http://github.com/audy/lederhosen"
  s.summary     = '16S rRNA clustering for paired-end Illumina'
  s.description = 'Cluster 16S rRNA amplicon data sequenced by paired-end Illumina into OTUs. Also, quality control data first!'

  s.rubyforge_project = "lederhosen"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('dna')
  s.add_dependency('thor')
  s.add_dependency('rspec')
  s.add_dependency('bundler')
  s.add_dependency('progressbar')
  s.add_dependency('bundler')
end