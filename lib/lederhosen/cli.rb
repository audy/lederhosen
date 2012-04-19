module Lederhosen
  class CLI < Thor
    include Thor::Actions

    no_tasks do
      # just print string to STDERR
      def ohai(s)
        $stderr.puts s
      end
    end

  end # class CLI

end # module

Dir.glob(File.join(File.dirname(__FILE__), 'tasks', '*.rb')).each { |f| require f }