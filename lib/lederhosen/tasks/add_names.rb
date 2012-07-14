##
# ADD TAXONOMIC DESCRIPTIONS TO OTU TABLE
#

module Lederhosen
	class CLI

		desc "add_names",
			"add names to otu abundance matrix using blat output and the out file"

		method_option :blat,   :type => :string, :required => true
		method_option :table,  :type => :string, :required => true
		method_option :level,  :type => :string, :required => true
		method_option :output, :type => :string, :required => false

	  def add_names
			blat =  options[:blat]
			table = options[:table]
			level = options[:level]
			output = options[:output] || $stdout

			levels = { 'kingdom' => 0, 
								 'domain'  => 0,
						  	 'phylum'  => 1,
								 'class'   => 2,
					  		 'order'   => 3,
					  	   'family'  => 4,
					  		 'genus'   => 5,
						  	 'species' => 6 }

			fail "unknown level. try #{levels.keys.join(', ')}" unless levels.include? level

			# Corresponds with the numbers used in the TaxCollector database
			# taxonomic descriptions
			level_no = levels[level]

			# map cluster_id to taxonomic description
			# default is the cluster_id itself in case
			# the cluster was not classified.
			clusterid_to_name = Hash.new { |h, k| h[k] = k }

			# map clusterid to name using blat output
			ohai "loading BLAT output from #{blat}"
			File.open(blat) do |handle|
				handle.each do |line|
					line = line.strip.split

					# Only get first match
					# TODO something smarter here
					cluster_id = line[0].split(':')[3]
					next if clusterid_to_name.include? cluster_id

					taxonomic_description = line[1]

					# match by level_no
					# Example:
					# [0]Bacteria;[1]Actinobacteria;[2]Actinobacteria;[3]Acidimicrobiales;[4]Acidimicrobiaceae;[5]Acidimicrobium;[6]Acidimicrobium_ferrooxidans;
					# I want to match Actinobacteria given level_no = 2
					level_name = taxonomic_description.match(/\[#{level_no}\](\w*)[;\[]/)[1] rescue next

					clusterid_to_name[cluster_id] = level_name
				end
			end

			# load table, replace cluster names with taxonomic descriptions
			output = File.open(output, 'w') unless output == $stdout
			ohai "replacing names in #{table}"
			File.open(table) do |handle|

				# read in header, replace clusterids to names
				header = handle.gets.strip.split(',')
				header[1..-1] = header[1..-1].map { |x| clusterid_to_name[x] }
				
				# print new header
				output.puts header.join(',')

				# print rest of table
				handle.each { |l| output.print l }
			end

			# print status message
			ohai "Got #{clusterid_to_name.keys.reject { |x| x =~ /cluster/ }.size} names (#{clusterid_to_name.keys.size} total)"
		end

	end
end
