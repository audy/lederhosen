require 'spec_helper'

lederhosen = Lederhosen::CLI.new

describe 'no_tasks' do

  let(:greengenes_taxonomy) { '124 U55236.1 Methanobrevibacter thaueri str. CW k__Archaea; p__Euryarchaeota; c__Methanobacteria; o__Methanobacteriales; f__Methanobacteriaceae; g__Methanobrevibacter; Unclassified; otu_127' }
  let(:taxcollector_taxonomy) { '[0]Bacteria;[1]Actinobacteria;[2]Actinobacteria;[3]null;[4]null;[5]null;[6]bacterium_TH3;[7]bacterium_TH3;[8]bacterium_TH3|M79434|8 ' } 

  it '#detect_taxonomy_format should recognize GreenGenes' do
    lederhosen.detect_taxonomy_format(greengenes_taxonomy).should == :greengenes
  end

  it '#detect_taxonomy_format should recognize TaxCollector' do
    lederhosen.detect_taxonomy_format(taxcollector_taxonomy).should == :taxcollector
  end

  it '#parse_taxonomy_taxcollector should parse taxcollector taxonomy' do
    taxonomy = lederhosen.parse_taxonomy_taxcollector(taxcollector_taxonomy)
    taxonomy['original'].should == taxcollector_taxonomy
    
    levels = %w{domain phylum class order family genus species kingdom original}

    taxonomy.keys.each do |v|
      levels.should include v
    end
  end

  it '#parse_taxonomy_greengenes should parse greengenes taxonomy' do
    taxonomy = lederhosen.parse_taxonomy_greengenes(greengenes_taxonomy)
    levels = %w{domain phylum class order family genus species kingdom original}

    taxonomy.keys.each do |v|
      levels.should include v
    end
  end

  it '#parse_taxonomy should automatically detect and parse greengenes taxonomy' do
    lederhosen.parse_taxonomy(greengenes_taxonomy).should_not be_nil
  end

  it '#parse_taxonomy should automatically detect and parse taxcollector taxonomy' do
    lederhosen.parse_taxonomy(taxcollector_taxonomy).should_not be_nil
  end
end
