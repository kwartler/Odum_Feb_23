#' Title: Dendrograms and Word Networks
#' Purpose: Use text for various HC and network visuals
#' Author: Ted Kwartler
#' email: edward.kwartler@faculty.hult.edu
#' License: GPL>=3
#' Date: Feb 8 2023
#'

# Set the working directory
setwd("~/Desktop/Odum_Feb_23/personal")

# Libs
library(tm)
library(qdap)
library(ggplot2)
library(ggthemes)
library(ggdendro)

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

tryTolower <- function(x){
  y <- NA
  tryError <- tryCatch(tolower(x), error = function(e) e)
  if (!inherits(tryError, 'error'))
    y <- tolower(x)
  return(y)
}

cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url))
  corpus <- tm_map(corpus, content_transformer(replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Create custom stop words
stops <- c(stopwords('SMART'), 'amp', 'britishairways', 'british',
           'flight', 'flights', 'airways')

# Read in Data, clean & organize
text <- read.csv('https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/lessons/Feb8/data/BritishAirways.csv')
txtCorpus <- VCorpus(VectorSource(text$text))
txtCorpus <- cleanCorpus(txtCorpus, stops)
tweetTDM  <- TermDocumentMatrix(txtCorpus)

# Reduce TDM
reducedTDM <- removeSparseTerms(tweetTDM, sparse=0.985) #shoot for ~50 terms; 1.5% of cells in row have a value  
reducedTDM

# Organize the smaller TDM
reducedTDM <- as.data.frame(as.matrix(reducedTDM))

# Basic Hierarchical Clustering
hc <- hclust(dist(reducedTDM))
plot(hc,yaxt='n')

ggdendrogram(hc, rotate=FALSE) 

############ Back to PPT

networkStops <- c(stops, 'britishairways', 'british', 'airways', 'rt')

assocText <- rm_url(text$text)

# MORE QDAP!
word_associate(assocText, 
               match.string = 'brewdog', 
               stopwords = networkStops,
               network.plot = T,
               cloud.colors = c('black','darkred'))

# MORE QDAP!
word_associate(assocText, 
               match.string = 'brewdog', 
               stopwords = networkStops,
               wordcloud = T,
               cloud.colors = c('black','darkred'))

# End

