module Lederhosen
	class CLI

		desc 'otu_filter', 'works like uc_filter but uses an OTU table as input'

		method_option :input, :type   =>  :string, :required => true
		method_option :output, :type  =>  :string, :required => true
		method_option :reads, :type   => :numeric, :required => true
		method_option :samples, :type => :numeric, :required => true

		def otu_filter
			input   = options[:input]
			output  = options[:output]
			reads   = options[:reads]
			samples = options[:samples]

			##
			# Iterate over otu table line by line.
			# Only print if cluster meets criteria
			#
			kept = 0
			File.open(input) do |handle|
			  header  = handle.gets.strip
				header  = header.split(',')
				samples = header[1..-1]
	
				puts header.join(',')

				handle.each do |line|
					line       = line.strip.split(',')
					cluster_no = line[0]
					counts     = line[1..-1].collect { |x| x.to_i }

					# should be the same as uc_filter
					if counts.reject { |x| x < reads }.length > samples
						puts line.join(',')
						kept += 1  
					end
				end
			end
			ohai "kept #{kept} clusters."
		end
		
	end
end
