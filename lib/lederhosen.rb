require 'rubygems'
require 'dna'
require 'progressbar'
require 'thor'

# files have to be required in order.
# changes depending on system.
%w{cli no_tasks uc_parser version}.each do |f|
  require File.join(File.dirname(__FILE__), 'lederhosen', "#{f}.rb")
end
