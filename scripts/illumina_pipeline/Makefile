#!/bin/bash

# for now, we use the Caporaso reference OTUs
# In the future, I would like to be able to generate a fresh
# OTU reference database from scratch.

REF_DB='http://greengenes.lbl.gov/Download/Sequence_Data/Fasta_data_files/Reference_OTUs_for_Pipelines/Caporaso_Reference_OTUs/gg_otus_4feb2011.tgz'

default: reference_otus

reference_otus:
	mkdir -p data
	curl -L ${REF_DB} > data/ref_otus.tar.gz
	tar -zxvf data/ref_otus.tar.gz # this will end up in some other directory
