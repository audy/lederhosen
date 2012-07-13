##
# SQUISH A CSV FILE BY COLUMN NAME
#

module Lederhosen
	class CLI

		desc 'squish', 'merge cell values (reads) in a csv file by column name (cluster)'
		
		method_option :csv_file, :type => :string, :required => true
		method_option :output,   :type => :string, :required => false

		def squish
			csv_file = options[:csv_file]
			output   = options[:output] || $stdout

			# sample_name -> column name -> total number of reads
			total_by_sample_by_column = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = 0 } }
			column_names = '' # scope
			# Load CSV file, merge counts in columns with the same name
			File.open(csv_file) do |handle|
				column_names = handle.gets.strip.split(',')[1..-1]
				handle.each do |line|
					line = line.strip.split(',')
					sample = line[0]
					line[1..-1].zip(column_names) do |reads, column_name|
						total_by_sample_by_column[sample][column_name] += reads.to_i
					end
				end
			end

			# print the new, squished csv file
			column_names.uniq!.sort!
			puts "-,#{column_names.join(',')}"
			total_by_sample_by_column.each_pair do |sample_id, row|
				print "#{sample_id}"
				column_names.each do |column_name|
					print ",#{row[column_name]}"
				end
				print "\n"
			end
		end
	end
end
