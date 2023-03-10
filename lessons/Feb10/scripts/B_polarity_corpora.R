#' Title: Polarity w/2+docs
#' Purpose: Learn and calculate polarity 
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Feb 8, 2023
#'

# WD
setwd("~/Desktop/Odum_Feb_23/personal")

# Libs
library(tm)
library(qdap)

# Data I
textA <- readLines('https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/lessons/Feb10/data/pharrell_williams_happy.txt')
textB <- readLines('https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/lessons/Feb10/data/starboy.txt')

# Organization
allTxt <- data.frame(artist = c('pharrell_williams','weeknd'),
                     song = c(textA, textB))

# Polarity on the entire corpus
polarity(allTxt$song)

# What about by group?
polarity(allTxt$song, grouping.var = allTxt$artist)
sentiment_by(allTxt$song, allTxt$artist)


# Examine the polarity obj more
pol <- polarity(allTxt$song, grouping.var = allTxt$artist)

# Groups
pol$all$artist

# Word Counts for each
pol$all$wc

# Polarity for each
pol$all$polarity

# Positive Terms
pol$all$pos.words[[1]] #happy
pol$all$pos.words[[2]] #starboy

# Negative Terms
pol$all$neg.words[[1]] #happy
pol$all$neg.words[[2]] #starboy

# Raw Text
cat(pol$all$text.var[1])
cat(pol$all$text.var[2])

# High Level Document/Group View
pol$group

# End