#' Title: Polarity on a corpus
#' Purpose: Learn and calculate polarity 
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Jan 29, 2023
#'

# WD
setwd("~/Desktop/Odum_Feb_23/personal")

# Libs
library(tm)
library(qdap)
library(sentimentr)

# Data I
text <- readLines('https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/lessons/Feb10/data/pharrell_williams_happy.txt')

# Polarity on the document
polarity(text) #qdap
sentimentr::sentiment_by(text)#sentimentr; diff calc & lexicon treating punctuation differently

# Does it Matter if we process it?
# Custom Functions
tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
  return(y)
}

cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

txt <- VCorpus(VectorSource(text))
txt <- cleanCorpus(txt, stopwords("SMART"))
polarity(content(txt[[1]])) #removing stopwords decreases the denominator 
sentiment(content(txt[[1]])) 

# Examine the polarity obj more
pol <- polarity(content(txt[[1]]))

# Word count detail
pol$all$wc

# Polarity Detail
pol$all$polarity

# Pos Words ID'ed
pol$all$pos.words

# Neg Words ID'ed
pol$all$neg.words

# What are the doc words after polarity processing?
cat(pol$all$text.var[[1]])

# Document View; no group variable so still lumped together
pol$group

# End
