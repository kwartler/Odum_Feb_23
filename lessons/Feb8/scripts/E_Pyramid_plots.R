#' Title: Pyramids plots
#' Purpose: Comparative visualizations for text
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
library(plotrix)
library(ggplot2)
library(ggthemes)
#library(ggalt)

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# Custom Functions
tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
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
stops <- c(stopwords('SMART'), 'amp', 'britishairways', 
           'british', 'flight', 'flights', 'airways', 
           'ryanair', 'airline', 'flying')

# Read in multiple files as individuals
txtFiles <- list.files(
  path        = '~/Desktop/Odum_Feb_23/lessons/Feb8/data',
  pattern     = 'british|ryan', 
  full.names  = T, 
  ignore.case = T)

# Bring them in 1 at a time instead of in a loop
txtLst <- lapply(txtFiles, read.csv)

#  Apply steps to each list element; Small changes since we need a TDM then simple matrix
for(i in 1:length(txtLst)){
  print(paste('working on',i, 'of', length(txtLst)))
  tmp <- paste(txtLst[[i]]$text, collapse = ' ')
  tmp <- VCorpus(VectorSource(tmp))
  tmp <- cleanCorpus(tmp, stops)
  tmp <- TermDocumentMatrix(tmp)
  txtLst[[i]] <- as.matrix(tmp)
}

# FYI
lapply(txtLst, dim)
head(txtLst[[1]])
head(txtLst[[2]])

# Merge based on the row attributes (terms)
df        <- merge(txtLst[[1]], txtLst[[2]], by ='row.names')

# Programmatically assign names
txtNames  <- sapply(strsplit(txtFiles, '/'), tail, 1)
names(df) <- c('terms', txtNames)

# Examine
df[6:10,]

# Calculate the absolute differences among in common terms
df$diff <- abs(df[,2] - df[,3])

# Organize df for plotting
df<- df[order(df$diff, decreasing=TRUE), ]
top35 <- df[1:35, ]

# Pyarmid Plot
pyramid.plot(lx         = top35[,2], #left
             rx         = top35[,3],    #right
             labels     = top35[,1],  #terms
             top.labels = c( names(top35)[2], names(top35)[1],  names(top35)[3]), #corpora
             gap        = 5, # space for terms to be read
             main       = 'Words in Common', # title
             unit       = 'wordFreq') 

# End
