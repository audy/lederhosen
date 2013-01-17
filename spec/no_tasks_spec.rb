require 'spec_helper'

describe 'no_tasks' do

  let(:greengenes_taxonomies) { ['124 U55236.1 Methanobrevibacter thaueri str. CW k__Archaea; p__Euryarchaeota; c__Methanobacteria; o__Methanobacteriales; f__Methanobacteriaceae; g__Methanobrevibacter; Unclassified; otu_127']}
  let(:qiime_taxonomies) { [ 'k__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Enterobacteriales;f__Enterobacteriaceae;g__Rahnella;s__' ]}
  let(:taxcollector_taxonomies) { ['[0]domain;[1]phylum;[2]class;[3]order;[4]family;[5]genus;[6]species;[7]strain;[8]Genus_species_strain_id'] }
  let(:lederhosen) { Lederhosen::CLI.new }

  it '#parse_usearch_line should parse a line of usearch output'

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

  %w{domain phylum class order family genus species strain}.each do |level|
    it "#parse_taxonomy_taxcollector should parse taxcollector taxonomy (#{level})" do
      taxcollector_taxonomies.each do |taxonomy|
        taxonomy = lederhosen.parse_taxonomy_taxcollector(taxonomy)
        taxonomy[level].should == level
      end
    end
  end
  
  it '#parse_taxonomy_taxcollector should return original taxonomy' do
    lederhosen.parse_taxonomy_taxcollector(taxcollector_taxonomies[0])['original'].should == taxcollector_taxonomies[0]
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

  it '#parse_taxonomy_greengenes should parse qiime taxonomy' do
    qiime_taxonomies.each do |qiime_taxonomy|
      taxonomy = lederhosen.parse_taxonomy_qiime(qiime_taxonomy)
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
