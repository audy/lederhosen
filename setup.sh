#!/bin/bash

echo "Note: You may need to be root.\n\nIf you get an error try running this:\n   $ sudo ./setup.sh\n"

if [ ! `which uclust` ]; then
  echo "NOTE: You must have uclust installed and in your \$PATH \n"
fi

echo "Installing Lederhosen dependencies"
for gem in dna bundler rspec thor progressbar; do
  gem install $gem --no-ri --no-rdoc > /dev/null
done

cp lederhosen.rb /usr/local/bin/lederhosen

echo "Installation complete.\n\nFor instructions, type\n\n   $ lederhosen help\n\nThank you for choosing Lederhosen."
