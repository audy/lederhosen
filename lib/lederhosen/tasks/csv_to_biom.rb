# supports biom format 1.0
# as specified here:
# http://biom-format.org/documentation/format_versions/biom-1.0.html

module Lederhosen
  class CLI

    desc 'csv_to_biom', 'convert csv file to biom format'

    method_option :otu_data, :type => :string, :required => true
    method_option :metadata, :type => :string, :required => false
    method_option :output,   :type => :string, :required => true

    def csv_to_biom
      otu_data = File.expand_path(options[:input])
      metadata = File.expand_path(options[:metadata]) rescue nil
      output   = File.expand_path(options[:output])

      base = {
        :id                  => 'null',
        :format              => 'biom-1.0',
        :format_url          => 'http://biom-format.org/documentation/format_versions/biom-1.0.html',
        :type                => 'OTU table',
        :generated_by        => Lederhosen::Version::STRING,
        :data                => Time.now.utc.iso8601,
        :matrix_type         => 'dense',
        :matrix_element_type => 'int',
        :comment             => '',
        :data                => [],
        :rows                => [],
        :columns             => [],
      }

      # LOAD OTU DATA
      # XXX biom format has columns/rows transposed

      File.open(otu_data) do |handle|
        header = handle.gets.strip.split(',')

        # add otu names as rows
        # this has to be in the same order as the rows in :data
        # TODO add support for metadata
        header.each do |otu_name|
          base[:rows].append { :id => otu_name, :metadata => 'null' }
        end

        # read reads per sample/otu. Add to 2x2 matrix
        handle.each do |line|
          sample_id = line[0]
          data = line[1..-1]
          header.zip(data).each do |v, m|
            otu_information[sample_id][v] = m
          end
        end

      end

    end

  end
end
