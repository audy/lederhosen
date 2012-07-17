$:.unshift File.join(File.dirname(__FILE__), '..')
require 'lederhosen'
require 'rspec'

$test_dir = ENV['TEST_DIR'] || "/tmp/lederhosen_test_#{(0...8).map{65.+(rand(25)).chr}.join}/"
`mkdir -p #{$test_dir}`
$stderr.puts "test dir: #{$test_dir}"
