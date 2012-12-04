require 'spec_helper'

lederhosen = Lederhosen::CLI.new

describe 'no_tasks' do

  let(:greengenes_taxonomies) { ['124 U55236.1 Methanobrevibacter thaueri str. CW k__Archaea; p__Euryarchaeota; c__Methanobacteria; o__Methanobacteriales; f__Methanobacteriaceae; g__Methanobrevibacter; Unclassified; otu_127',
                                 'k__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Enterobacteriales;f__Enterobacteriaceae;g__Rahnella;s__' ]}
  let(:taxcollector_taxonomies) { ['[0]Bacteria;[1]Actinobacteria;[2]Actinobacteria;[3]null;[4]null;[5]null;[6]bacterium_TH3;[7]bacterium_TH3;[8]bacterium_TH3|M79434|8'] }

  it '#detect_taxonomy_format should recognize GreenGenes' do
    greengenes_taxonomies.each do |greengenes_taxonomy|
      lederhosen.detect_taxonomy_format(greengenes_taxonomy).should == :greengenes
    end
  end

  it '#detect_taxonomy_format should recognize TaxCollector' do
    taxcollector_taxonomies.each do |taxcollector_taxonomy|
      lederhosen.detect_taxonomy_format(taxcollector_taxonomy).should == :taxcollector
    end
  end

  it '#detect_taxonomy_format should fail on unknown formats' do
    lederhosen.detect_taxonomy_format('this is not a taxonomic description').should raise_error
  end

  it '#parse_taxonomy_taxcollector should parse taxcollector taxonomy' do
    taxcollector_taxonomies.each do |taxcollector_taxonomy|
      taxonomy = lederhosen.parse_taxonomy_taxcollector(taxcollector_taxonomy)
      taxonomy['original'].should == taxcollector_taxonomy

      levels = %w{domain phylum class order family genus species kingdom original strain}

      taxonomy.keys.each do |v|
        levels.should include v
      end
    end
  end

  it '#parse_taxonomy_greengenes should parse greengenes taxonomy' do
    greengenes_taxonomies.each do |greengenes_taxonomy|
      taxonomy = lederhosen.parse_taxonomy_greengenes(greengenes_taxonomy)
      levels = %w{domain phylum class order family genus species kingdom original}

      taxonomy.keys.each do |v|
        levels.should include v
      end
    end
  end

  it '#parse_taxonomy should automatically detect and parse greengenes taxonomy' do
    greengenes_taxonomies.each do |greengenes_taxonomy|
      lederhosen.parse_taxonomy(greengenes_taxonomy).should_not be_nil
    end
  end

  it '#parse_taxonomy should automatically detect and parse taxcollector taxonomy' do
    taxcollector_taxonomies.each do |taxcollector_taxonomy|
      lederhosen.parse_taxonomy(taxcollector_taxonomy).should_not be_nil
    end
  end

  it '#parse_taxonomy_taxcollector should replace unclassified species names with strain name' do
    t = '[0]Bacteria;[1]Actinobacteria;[2]Actinobacteria;[3]Actinomycetales;[4]test;[5]null;[6]Propionibacterineae_bacterium;[7]Propionibacterineae_bacterium_870BRRJ;[8]Propionibacterineae_bacterium_870BRRJ|genus'
    tax = lederhosen.parse_taxonomy(t)
    tax['species'].should == tax['strain']
  end
end
