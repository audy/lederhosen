#!/bin/bash

echo "Note: You may need to be root.\n\nIf you get an error try running this:\n   $ sudo ./setup.sh\n"

cp lederhosen.rb /usr/local/bin/lederhosen

echo "Installing Lederhosen"
for gem in dna bundler rspec thor; do
  gem install $gem --no-ri --no-rdoc > /dev/null
done

echo "Installation complete.\n\nFor instructions, type\n\n   $ lederhosen help\n\nThank you for choosing Lederhosen."
