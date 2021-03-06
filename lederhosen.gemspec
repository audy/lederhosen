# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: lederhosen 3.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "lederhosen"
  s.version = "3.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Austin G. Davis-Richardson"]
  s.date = "2014-04-16"
  s.description = "Various tools for OTU clustering"
  s.email = "harekrishna@gmail.com"
  s.executables = ["lederhosen"]
  s.extra_rdoc_files = [
    "LICENSE.txt"
  ]
  s.files = [
    ".rspec",
    ".travis.yml",
    "Gemfile",
    "LICENSE.txt",
    "Rakefile",
    "bin/lederhosen",
    "lederhosen.gemspec",
    "lib/lederhosen.rb",
    "lib/lederhosen/cli.rb",
    "lib/lederhosen/no_tasks.rb",
    "lib/lederhosen/tasks/cluster.rb",
    "lib/lederhosen/tasks/count_taxonomies.rb",
    "lib/lederhosen/tasks/get_reps.rb",
    "lib/lederhosen/tasks/join_otu_tables.rb",
    "lib/lederhosen/tasks/make_udb.rb",
    "lib/lederhosen/tasks/otu_filter.rb",
    "lib/lederhosen/tasks/otu_table.rb",
    "lib/lederhosen/tasks/separate_unclassified.rb",
    "lib/lederhosen/tasks/split_fasta.rb",
    "lib/lederhosen/tasks/version.rb",
    "lib/lederhosen/uc_parser.rb",
    "lib/lederhosen/version.rb",
    "logo.png",
    "readme.md",
    "scripts/count_taxonomies.go",
    "scripts/illumina_pipeline/.gitignore",
    "scripts/illumina_pipeline/Makefile",
    "scripts/illumina_pipeline/pipeline.sh",
    "scripts/illumina_pipeline/readme.md",
    "scripts/otu_ref_picking/readme.md",
    "scripts/readme.md",
    "spec/cli_spec.rb",
    "spec/data/test.uc",
    "spec/data/trimmed/ILT_L_9_B_001.fasta",
    "spec/no_tasks_spec.rb",
    "spec/spec_helper.rb",
    "spec/uc_parser_spec.rb"
  ]
  s.homepage = "http://audy.github.com/lederhosen"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "OTU Clustering"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dna>, ["= 0.3.0"])
      s.add_runtime_dependency(%q<progressbar>, ["= 0.12.0"])
      s.add_runtime_dependency(%q<thor>, ["= 0.16.0"])
      s.add_development_dependency(%q<jeweler>, ["= 1.8.4"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
    else
      s.add_dependency(%q<dna>, ["= 0.3.0"])
      s.add_dependency(%q<progressbar>, ["= 0.12.0"])
      s.add_dependency(%q<thor>, ["= 0.16.0"])
      s.add_dependency(%q<jeweler>, ["= 1.8.4"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
    end
  else
    s.add_dependency(%q<dna>, ["= 0.3.0"])
    s.add_dependency(%q<progressbar>, ["= 0.12.0"])
    s.add_dependency(%q<thor>, ["= 0.16.0"])
    s.add_dependency(%q<jeweler>, ["= 1.8.4"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
  end
end

