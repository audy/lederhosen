$:.unshift File.join(File.dirname(__FILE__), '..')

require 'lederhosen'
require 'bundler'

Bundler.require :test, :development

Coveralls.wear!

$test_dir = ENV['TEST_DIR'] || "/tmp/lederhosen_test_#{(0...8).map{65.+(rand(25)).chr}.join}/"
`mkdir -p #{$test_dir}`
$stderr.puts "test dir: #{$test_dir}"

RSpec.configure do |c|
  # check if usearch is in $PATH
  # if not, skip usearch tests.
  usearch = `which usearch`
  if usearch == ''
    c.filter_run_excluding :requires_usearch => true
  end
end
