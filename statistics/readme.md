# Statistics

Various statistics and plotting scripts compatible with Lederhosen outputs.

## Requirements

- R
- reshape
- ggplot2

Get R at [r-project.org](http://www.r-project.org/) then install ggplot2 and reshape by pasting this command:

`r -q -e "install.packages(c('reshape', 'ggplot2'))"`

## Plots

### Cluster Survival

`./plot_cluster_survival.r otus.csv`

Plots number of clusters (y) that remain after removing those with less than n reads as n goes from 0 to max_cluster_size (x).

![Plot Image Survival](http://i.imgur.com/d8LFR.png)
