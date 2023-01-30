#' Title: Text Organization for Bag of Words
#' Purpose: Learn some basic cleaning functions & term frequency
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Jan 29, 2023
#'

# WD
setwd("~/Desktop/Odum_Feb_23/personal")

# Libs
library(tm)

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

tryTolower <- function(x){
  y <- NA # default is NA
  tryError <- tryCatch(tolower(x), error = function(e) e) # tryCatch error
  if (!inherits(tryError, 'error'))   
    y <- tolower(x) # if not an error
  return(y) 
}

cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url)) 
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stripWhitespace)
  return(corpus)
}

# Create custom stop words
stops <- c(stopwords('english'), 'lol', 'smh')

# Data
text <- read.csv('https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/lessons/Feb6/data/coffee.csv')

# As of tm version 0.7-3 tabular was deprecated
names(text)
names(text)[1] <- 'doc_id' #first 2 columns must be 'doc_id' & 'text'

# Make a volatile corpus
txtCorpus <- VCorpus(DataframeSource(text))

# Preprocess the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# Check Meta Data; brackets matter!!
txtCorpus[[4]]
meta(txtCorpus[[4]]) #double [[...]]
t(meta(txtCorpus[4])) #single [...]

content(txtCorpus[4]) #single [...]
content(txtCorpus[[4]]) #double [...]

# use sapply for a character vector of clean text
cleanTextVec <- sapply(txtCorpus, content)

# Compare a single tweet
text$text[4]
cleanTextVec[4]

# Make a Document Term Matrix or Term Document Matrix depending on analysis
##  **you don't need to have both in your analysis, just choose 1**
txtDtm  <- DocumentTermMatrix(txtCorpus)
txtTdm  <- TermDocumentMatrix(txtCorpus)
txtDtmM <- as.matrix(txtDtm)
txtTdmM <- as.matrix(txtTdm)

# Examine
mugs <- grep('mug',colnames(txtDtmM))
txtDtmM[4:6,mugs]
txtTdmM[mugs,4:6]

#### Go back to PPT ####

# Get the most frequent terms
topTermsA <- colSums(txtDtmM)
topTermsB <- rowSums(txtTdmM)

# Add the terms
topTermsA <- data.frame(terms     = colnames(txtDtmM), 
                        freq      = topTermsA,
                        row.names = NULL)
topTermsB <- data.frame(terms     = rownames(txtTdmM), 
                        freq      = topTermsB,
                        row.names = NULL)

# Review
head(topTermsA)
head(topTermsB)

# Which term is the most frequent?
idx <- which.max(topTermsA$freq)
topTermsA[idx, ]

# End
