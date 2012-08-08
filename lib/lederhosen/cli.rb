module Lederhosen
  class CLI < Thor
    include Thor::Actions

    no_tasks do
      def ohai(s)
        @shell.say_status('okay', s, 'green')
      end

      def ohno(s)
        @shell.say_status('fail', s, 'red')
        exit(-1)
      end
    end

    @shell = Thor::Shell::Basic.new

  end # class CLI

end # module

Dir.glob(File.join(File.dirname(__FILE__), 'tasks', '*.rb')).each { |f| require f }
