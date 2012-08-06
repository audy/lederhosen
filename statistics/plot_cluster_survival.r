#!/usr/bin/env rscript

# plot cluster survival rate given an OTU abundance matrix
# (y - number of samples w/ clusters w/ more than n reads)
# (x - n)
# usage ./plot_cluster_survival.r otus.csv
# will create Rplots.pdf

require('ggplot2')
require('reshape')

input_file = commandArgs()[6]
dat        = read.csv(input_file)

dat = melt(dat)

f = data.frame()

for (i in 1:max(dat$value)) {
  n = nrow(subset(dat, value > i))
  f = rbind(f, data.frame(n=n, i=i))
}

ggplot(f, aes(x=n, y=i)) + geom_point()
