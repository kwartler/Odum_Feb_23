#' Title: Frequency and Associations
#' Purpose: Obtain term frequency and explore associations
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
library(ggplot2)
library(ggthemes)

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
text      <- read.csv('https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/lessons/Feb8/data/BritishAirways.csv')
txtCorpus <- VCorpus(VectorSource(text$text))
txtCorpus <- cleanCorpus(txtCorpus, stops)
tweetTDM  <- TermDocumentMatrix(txtCorpus)
tweetTDMm <- as.matrix(tweetTDM)

# Frequency Data Frame
tweetSums <- rowSums(tweetTDMm)
tweetFreq <- data.frame(word      = names(tweetSums),
                        frequency = tweetSums,
                        row.names = NULL)

# Review a section
tweetFreq[50:55,]

# Simple barplot; values greater than 15
topWords      <- subset(tweetFreq, tweetFreq$frequency >= 15) 
topWords      <- topWords[order(topWords$frequency, decreasing=F),]

# Make the plot w/nested reorder()
ggplot(topWords, aes(x=reorder(word,frequency), y=frequency)) + 
  geom_bar(stat="identity", fill='darkred') + 
  coord_flip()+ theme_gdocs() +
  geom_text(aes(label=frequency), colour="white",hjust=1.25, size=3.0)

# qdap version, slightly different results based on params but faster
plot(freq_terms(text$text, top=35, at.least=2, stopwords = stops))

############ Back to PPT

# Inspect word associations
associations <- findAssocs(tweetTDM, 'brewdog', 0.30)
associations

# Organize the word associations
assocDF <- data.frame(terms     = names(associations[[1]]),
                      value     = unlist(associations), 
                      row.names = NULL)
assocDF$terms <- factor(assocDF$terms, levels=assocDF$terms)
assocDF

# Make a dot plot
ggplot(assocDF, aes(y=terms)) +
  geom_point(aes(x=value), data=assocDF, col='#c00c00') +
  theme_gdocs() + 
  geom_text(aes(x=value,label=value), 
            colour="red",hjust="inward", vjust ="inward" , size=3) 

# End
