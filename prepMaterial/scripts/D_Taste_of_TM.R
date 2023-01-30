#' Title: Quick Taste of what's to come
#' Purpose: Learn some basic functions
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Jan 29, 2023
#'

# 1. WD
setwd("~/Desktop/Odum_Feb_23/personal")

# 2. Libs
library(sentimentr)
library(tm)
library(ggthemes)
library(ggplot2)

# 3. Data
txt <- read.csv("https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/prepMaterial/data/exampleNews.csv" )

# 4. Apply some functions
emoNews <- emotion_by(txt$description, txt$name) #emotion
polNews <- sentiment_by(txt$description, txt$name) #pos/neg

# 5. Polarity by Source
barplot(polNews$ave_sentiment, names.arg = polNews$name, las= 2)

# Drop Negation Emotions & focus on the other emotions
emoNewsNegation <- emoNews[-grep('negated', emoNews$emotion_type),]
keeps <- grepl('anger|disgust|fear|sadness', emoNewsNegation$emotion_type)
emoNewsNegation <- emoNewsNegation[keeps, ]
ggplot(emoNewsNegation) + 
  geom_col(aes(x = name, y = emotion_count, fill = emotion_type)) + 
  theme_gdocs()

# End