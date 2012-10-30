# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "lederhosen"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Austin G. Davis-Richardson"]
  s.date = "2012-10-30"
  s.description = "Various tools for OTU clustering"
  s.email = "harekrishna@gmail.com"
  s.executables = ["lederhosen"]
  s.extra_rdoc_files = [
    "LICENSE.txt"
  ]
  s.files = [
    ".rspec",
    ".rvmrc",
    "Gemfile",
    "LICENSE.txt",
    "Rakefile",
    "bin/lederhosen",
    "examples/hierarchical_clustering.sh",
    "examples/pipeline.sh",
    "lederhosen.gemspec",
    "lib/lederhosen.rb",
    "lib/lederhosen/buffer.rb",
    "lib/lederhosen/cli.rb",
    "lib/lederhosen/helpers.rb",
    "lib/lederhosen/tasks/cluster.rb",
    "lib/lederhosen/tasks/k_filter.rb",
    "lib/lederhosen/tasks/make_udb.rb",
    "lib/lederhosen/tasks/otu_filter.rb",
    "lib/lederhosen/tasks/otu_table.rb",
    "lib/lederhosen/tasks/rep_reads.rb",
    "lib/lederhosen/tasks/split.rb",
    "lib/lederhosen/tasks/split_fasta.rb",
    "lib/lederhosen/tasks/trim.rb",
    "lib/lederhosen/tasks/uc_filter.rb",
    "lib/lederhosen/tasks/uc_stats.rb",
    "lib/lederhosen/tasks/version.rb",
    "lib/lederhosen/version.rb",
    "readme.md",
    "spec/cli_spec.rb",
    "spec/data/ILT_L_9_B_001_1.txt.gz",
    "spec/data/ILT_L_9_B_001_3.txt.gz",
    "spec/data/ILT_L_9_B_002_1.txt.gz",
    "spec/data/ILT_L_9_B_002_3.txt.gz",
    "spec/data/test.uc",
    "spec/helpers_spec.rb",
    "spec/misc_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://audy.github.com/lederhosen"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "OTU Clustering"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dna>, ["= 0.0.12"])
      s.add_runtime_dependency(%q<progressbar>, [">= 0"])
      s.add_runtime_dependency(%q<thor>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
    else
      s.add_dependency(%q<dna>, ["= 0.0.12"])
      s.add_dependency(%q<progressbar>, [">= 0"])
      s.add_dependency(%q<thor>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
    end
  else
    s.add_dependency(%q<dna>, ["= 0.0.12"])
    s.add_dependency(%q<progressbar>, [">= 0"])
    s.add_dependency(%q<thor>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
  end
end

