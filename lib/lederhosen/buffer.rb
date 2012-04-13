module Lederhosen

  class Buffer
    # for when you need to write out to a shitload of files.

    #
    # Create a new buffer
    #
    def initialize(args={})
      @buffer = Hash.new { |h, k| h[k] = Array.new }
      @buffer_max = args[:buffer_max] || 100_000
    end

    #
    # Add an object to the buffer
    #
    def add_to bucket, obj

      @buffer[bucket] << obj.to_s

      if @buffer[bucket].length > @buffer_max
        # write out
        File.open(bucket, 'a+') do |out|
          @buffer[bucket].each do |v|
            out.puts v
          end
        end

        # clear that bucket
        @buffer[bucket].clear
      end
    end

    def [] k
      @buffer[k]
    end

    #
    # Writes out leftover objects
    #
    def finalize
      @buffer.each_key do |bucket|
        File.open(bucket, 'a+') do |out|
          @buffer[bucket].each do |v|
            out.puts v
          end
        end
      end
      @buffer = Hash.new { |h, k| h[k] = Array.new }
    end
  
  end

end