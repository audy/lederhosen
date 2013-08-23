require 'spec_helper'

describe 'Lederhosen::CLI.no_tasks' do

  let(:greengenes_taxonomies) { ['124 U55236.1 Methanobrevibacter thaueri str. CW k__domain; p__phylum; c__class; o__order; f__family; g__genus; species; otu_127']}
  let(:greengenes135_taxonomies) { ['k__domain; p__phylum; c__class; o__order; f__family; g__genus; s__species']}
  let(:qiime_taxonomies) { [ 'k__domain;p__phylum;c__class;o__order;f__family;g__genus;s__species' ]}
  let(:taxcollector_taxonomies) { ['[0]domain;[1]phylum;[2]class;[3]order;[4]family;[5]genus;[6]species;[7]strain;[8]Genus_species_strain_id'] }
  let(:lederhosen) { Lederhosen::CLI.new }

  it '#parse_usearch_line should parse a line of usearch output'

  it '#detect_taxonomy_format should recognize GreenGenes' do
    greengenes_taxonomies.each do |greengenes_taxonomy|
      lederhosen.detect_taxonomy_format(greengenes_taxonomy).should == :greengenes
    end
  end

  it '#detect_taxonomy_format should recognize GreenGenes v13.5' do
    greengenes135_taxonomies.each do |greengenes_taxonomy|
      lederhosen.detect_taxonomy_format(greengenes_taxonomy).should == :greengenes_135
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

  %w{domain phylum class order family genus species}.each do |level|

    it "#parse_taxonomy_taxcollector should parse taxcollector taxonomy (#{level})" do
      taxcollector_taxonomies.each do |taxonomy|
        taxonomy = lederhosen.parse_taxonomy_taxcollector(taxonomy)
        taxonomy[level].should == level
      end
    end

    it "#parse_taxonomy_greengenes should parse greengenes taxonomy (#{level})" do
      greengenes_taxonomies.each do |greengenes_taxonomy|
        taxonomy = lederhosen.parse_taxonomy_greengenes(greengenes_taxonomy)
        taxonomy[level].should == level
      end
    end

    it "#parse_taxonomy_greengenes_135 should parse greengenes v13.5 taxonomy (#{level})" do
      greengenes135_taxonomies.each do |greengenes_taxonomy|
        taxonomy = lederhosen.parse_taxonomy_greengenes_135(greengenes_taxonomy)
        taxonomy[level].should == level
      end
    end

    it "#parse_taxonomy_greengenes should parse qiime taxonomy (#{level})" do
      qiime_taxonomies.each do |qiime_taxonomy|
        taxonomy = lederhosen.parse_taxonomy_qiime(qiime_taxonomy)
        taxonomy[level].should == level
      end
    end

  end

  it '#parse_taxonomy_taxcollector should return original taxonomy' do
    lederhosen.parse_taxonomy_taxcollector(taxcollector_taxonomies[0])['original'].should == taxcollector_taxonomies[0]
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

  it '#parse_taxonomy should automatically detect and parse greengenes 13.5 taxonomy' do
    greengenes135_taxonomies.each do |greengenes_taxonomy|
      lederhosen.parse_taxonomy(greengenes_taxonomy).should_not be_nil
    end
  end

  it '#parse_taxonomy_taxcollector should replace unclassified species names with strain name' do
    t = '[0]Bacteria;[1]Actinobacteria;[2]Actinobacteria;[3]Actinomycetales;[4]test;[5]null;[6]Propionibacterineae_bacterium;[7]Propionibacterineae_bacterium_870BRRJ;[8]Propionibacterineae_bacterium_870BRRJ|genus'
    tax = lederhosen.parse_taxonomy(t)
    tax['species'].should == tax['strain']
  end

end
