#' Title: Simple Word Cloud
#' Purpose: Build a word cloud with bi-grams
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Jan 29, 2023
#'

# WD
setwd("~/Desktop/Odum_Feb_23/personal")

# Libs
library(tm)
library(qdap) # Comment out if you have qdap problems
library(wordcloud)
library(RColorBrewer)

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
  #corpus <- tm_map(corpus, content_transformer(replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Create custom stop words
stops <- c(stopwords('english'), 'lol', 'amp', 'and', 'chardonnay')

# Bigram token maker
bigramTokens <-function(x){
  unlist(lapply(NLP::ngrams(words(x), 2), paste, collapse = " "), 
         use.names = FALSE)
}

# Data
text <- read.csv('https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/lessons/Feb8/data/chardonnay.csv')

# As of tm version 0.7-3 tabular was deprecated
names(text)[1] <-'doc_id' 

# Make a volatile corpus
txtCorpus <- VCorpus(DataframeSource(text))

# Preprocess the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# Make bi-gram TDM according to the tokenize control & convert it to matrix
wineTDM  <- TermDocumentMatrix(txtCorpus, 
                               control=list(tokenize=bigramTokens))
wineTDMm <- as.matrix(wineTDM)

# See a bi-gram
exampleTweet <- grep('wine country', rownames(wineTDMm))
wineTDMm[(exampleTweet-2):(exampleTweet),870:871]

# Get Row Sums & organize
wineTDMv <- sort(rowSums(wineTDMm), decreasing = TRUE)
wineDF   <- data.frame(word      = names(wineTDMv), 
                       freq      = wineTDMv,
                       row.names = NULL)

# Review all Palettes
display.brewer.all()

# Choose a color & drop light ones
pal <- brewer.pal(8, "Purples")
pal <- pal[-(1:2)]

# Make simple word cloud
# Reminder to expand device pane
set.seed(1234)
wordcloud(wineDF$word,
          wineDF$freq,
          max.words    = 50,
          random.order = FALSE,
          colors       = pal,
          scale        = c(2,1))


# UNC Palette!
# Carolina Blue #4B9CD3
# Navy #13294B
wordcloud(wineDF$word,
          wineDF$freq,
          max.words    = 50,
          random.order = FALSE,
          colors       = c('#4B9CD3','#13294B'),
          scale        = c(2,1))

# End
