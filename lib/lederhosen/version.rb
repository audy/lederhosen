module Lederhosen
  module Version
    MAJOR = 3
    MINOR = 0
    CODENAME = 'Biergarten' # changes for minor versions
    PATCH = 0
    PRE = 'dev'

    string = [MAJOR, MINOR, PATCH].join('.')
    if PRE
      string = string + "-#{PRE}"
    end
    
    STRING = string
  end
end
