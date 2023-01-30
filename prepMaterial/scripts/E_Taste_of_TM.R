#' Title: Quick Taste of what's to come
#' Purpose: Learn some basic functions
#' Author: Ted Kwartler
#' email: edward.kwartler@faculty.hult.edu
#' License: GPL>=3
#' Date: Jan 18 2022
#'

# 1. WD
setwd("~/Desktop/Hult_NLP_student_intensive/lessons/class1/data")

# 2. Libs
library(sentimentr)
library(tm)
library(RCurl)
library(ggthemes)
library(ggplot2)

# 3. Data
#gitFile <- url('https://raw.githubusercontent.com/kwartler/Hult_NLP_student_intensive/main/lessons/class1/data/exampleNews.csv')
#txt <- read.csv(gitFile)
txt <- read.csv("exampleNews.csv" )

# 4. Apply some functions
emoNews <- emotion_by(txt$description, txt$name)
polNews <- sentiment_by(txt$description, txt$name)

# 5. Polarity by Source
barplot(polNews$ave_sentiment, names.arg = polNews$name, las= 2)

# Drop Negation Emotions & focus on the positve
emoNewsNegation <- emoNews[-grep('negated', emoNews$emotion_type),]
keeps <- grepl('anger|disgust|fear|sadness', emoNewsNegation$emotion_type)
emoNewsNegation <- emoNewsNegation[keeps, ]
ggplot(emoNewsNegation) + 
  geom_col(aes(x = name, y = emotion_count, fill = emotion_type)) + 
  theme_gdocs()

# End