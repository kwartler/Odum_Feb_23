#' Title: Sentiment Analysis
#' Purpose: Inner join sentiment lexicons to text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Feb 8, 2023
#'

# WD
setwd("~/Desktop/Odum_Feb_23/personal")

# Libs
library(tm)
library(lexicon)
library(tidytext)
library(dplyr)
library(qdap)
library(echarts4r)
library(tidyr)
library(corpus)
library(textdata)

# Functions
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
stops <- c(stopwords('english'))

# Clean and Organize the old way instead of cleanMatrix
txt <- read.csv('https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/lessons/Feb10/data/news.csv')
table(txt$doc_id) #565 news articles mentioning President Trump


# Ignoring authorship/news political leanings, overall let's examine the emotional words used in these articles
txtDTM <- VCorpus(VectorSource(txt$text))
txtDTM <- cleanCorpus(txtDTM, stops)
txtDTM <- DocumentTermMatrix(txtDTM)

# Examine 
as.matrix(txtDTM[1:5,100:105])
dim(txtDTM)

# Examine Tidy & Compare
tidyCorp <- tidy(txtDTM)
tidyCorp[100:105,]
dim(tidyCorp)

# Get bing lexicon
# "afinn", "bing", "nrc", "loughran"
bing <- get_sentiments(lexicon = c("bing"))
head(bing)

# Perform Inner Join
bingSent <- inner_join(tidyCorp, bing, by=c('term' = 'word'))
bingSent

# Quick Analysis
aggregate(count~sentiment,bingSent, sum) #correct way to sum them

# Compare original with qdap::Polarity
polarity(txt$text)
# avg. polarity  -0.013; about even pos/neg terms

# Get afinn lexicon
afinn<-get_sentiments(lexicon = c("afinn"))
head(afinn)

# Perform Inner Join
afinnSent <- inner_join(tidyCorp,afinn, by=c('term' = 'word'))
afinnSent

# Examine the quantity
afinnSent$afinnAmt     <- afinnSent$count * afinnSent$value

# Compare w/polarity and bing
mean(afinnSent$afinnAmt)
plot(density(afinnSent$afinnAmt))
 
# Check with the pptx for a reminder.
# Get nrc lexicon; deprecated in tidytext, use library(lexicon)
#nrc <- read.csv('https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/lessons/Feb10/data/nrcSentimentLexicon.csv')
nrc <- nrc_emotions
head(nrc)

# Tidy this up
nrc <- nrc %>% pivot_longer(-term, names_to = "emotion", values_to = "freq")
nrc <-subset(nrc, nrc$freq>0 )
head(nrc)
nrc$freq <- NULL #no longer needed

# Perform Inner Join
nrcSent <- inner_join(tidyCorp,nrc, by=c('term' = 'term'))
nrcSent

# Radar chart
table(nrcSent$emotion)
emos <- data.frame(table(nrcSent$emotion))
names(emos) <- c('emotion', 'termsCt')
emos %>% 
  e_charts(emotion) %>% 
  e_radar(termsCt, max = max(emos$termsCt), name = "President Trump 565 Articles Emotions") %>%
  e_tooltip(trigger = "item") %>% e_theme("dark-mushroom")

# Other Emotion Lexicons Exist
emotionLex <- affect_wordnet
emotionLex
table(emotionLex$emotion)
table(emotionLex$category)

emotionLex <- subset(emotionLex, 
                     emotionLex$emotion=='Positive'|emotionLex$emotion=='Negative')

# More emotional categories, fewer terms
lexSent <- inner_join(tidyCorp,emotionLex, by=c('term' = 'term'))
lexSent
emotionID <- aggregate(count ~ category, lexSent, sum)
emotionID %>% 
  e_charts(category) %>% e_theme("dark-mushroom") %>%
  e_radar(count, max =max(emotionID$count), name = "President Trump 565 Articles Emotional Categories") %>%
  e_tooltip() %>%
  e_theme("dark-mushroom") 

# Other lexicons worth exploring:
# https://ai.googleblog.com/2021/10/goemotions-dataset-for-fine-grained.html
# http://sentiment.christopherpotts.net/lexicons.html
# End