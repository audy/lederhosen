##
# Print version string and exit
#

module Lederhosen
  class CLI

    desc 'version', 'print version string and exit'

    def version
      puts "lederhosen-#{Lederhosen::Version::STRING}"
    end
  end
end
