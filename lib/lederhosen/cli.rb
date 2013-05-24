module Lederhosen

  ##
  # The CLI class holds all of the Thor tasks
  #
  class CLI < Thor
    include Thor::Actions

    no_tasks do

      ##
      # print a status message to $stderr
      # use for good statuses
      #
      def ohai(s)
        @shell.say_status('okay', s, 'green')
      end

      ##
      # print a status message to $stderr
      # use for bad statuses
      # also exit's with -1 status-code
      #
      def ohno(s)
        @shell.say_status('fail', s, 'red')
        exit(-1)
      end
    end

    @shell = Thor::Shell::Basic.new

  end # class CLI

end # module

Dir.glob(File.join(File.dirname(__FILE__), 'tasks', '*.rb')).each { |f| require f }