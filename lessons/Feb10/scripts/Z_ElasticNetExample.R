#' Title: Elastic net example
#' Purpose: Build an elastic net for classification 
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Jan 29, 2023
#'

# WD
setwd("~/Desktop/Odum_Feb_23/personal")

# Libs
library(text2vec)
library(caret)
library(tm)
library(glmnet)

# Custom cleaning function
diagnosisClean<-function(xVec){
  xVec <- removePunctuation(xVec)
  xVec <- stripWhitespace(xVec)
  xVec <- tolower(xVec)
  return(xVec)
}

# Read
diabetes <- read.csv('https://raw.githubusercontent.com/kwartler/Odum_Feb_23/main/lessons/Feb10/data/diabetes_subset_8500.csv')

# Concantenate texts in 3 columns
diabetes$diagnosisText <- as.character(paste(diabetes$diag_1_desc,
                                             diabetes$diag_2_desc,
                                             diabetes$diag_3_desc, sep=' '))

### SAMPLE : Patritioning
idx              <- createDataPartition(diabetes$readmitted,p=.7,list=F)
trainDiabetesTxt <- diabetes[idx,]
testDiabetesTxt  <- diabetes[-idx,]

### EXPLORE
head(trainDiabetesTxt$diagnosisText,2)

table(trainDiabetesTxt$readmitted)

### MODIFY
# 
trainDiabetesTxt$diagnosisText <- diagnosisClean(trainDiabetesTxt$diagnosisText)

# Initial iterator to make vocabulary
iterMaker <- itoken(trainDiabetesTxt$diagnosisText, 
                    preprocess_function = list(tolower), 
                    progressbar         = T)
textVocab <- create_vocabulary(iterMaker, stopwords=stopwords('SMART'))
head(textVocab)
tail(textVocab)
nrow(textVocab)

#prune vocab to make DTM smaller
prunedtextVocab <- prune_vocabulary(textVocab,
                                    term_count_min = 10,
                                    doc_proportion_max = 0.5,
                                    doc_proportion_min = 0.001)
nrow(prunedtextVocab)

# Using the pruned vocabulary to declare the DTM vectors 
vectorizer <- vocab_vectorizer(prunedtextVocab)

# Take the vocabulary lexicon and the pruned text function to make a DTM 
diabetesDTM <- create_dtm(iterMaker, vectorizer)
dim(diabetesDTM)

# Default is TF but if you want TF-IDF
#idf         <- get_idf(diabetesDTM)
#diabetesDTM <- transform_tfidf(diabetesDTM,idf)

### MODEL(s)
#train text only model
textFit <- cv.glmnet(diabetesDTM,
                     y=as.factor(trainDiabetesTxt$readmitted),
                     alpha=0.9,
                     family='binomial',
                     type.measure='auc',
                     nfolds=5,
                     intercept=F)


# Examine
head(coefficients(textFit),10)

# Subset to impacting terms
bestTerms <- subset(as.matrix(coefficients(textFit)), 
                    as.matrix(coefficients(textFit)) !=0)
head(bestTerms)
nrow(bestTerms)
ncol(diabetesDTM)

# Make training predictions
trainingPreds <- predict(textFit, diabetesDTM, type = 'class')
confusionMatrix(as.factor(trainingPreds),
                as.factor(trainDiabetesTxt$readmitted))

# Now that the model is built you need to process text for "new" and unseen patients
# Tokenize the unseen observations
testIter <- itoken(testDiabetesTxt$diagnosisText, 
                   preprocess_function = list(tolower), 
                   progressbar         = T)
# Use the original training set vectorizer function to retain the original terms 
testDTM <- create_dtm(testIter, vectorizer)

# Compare dimensions
dim(diabetesDTM) #training vocab
dim(testDTM) #unseen vocab after processing

# Make Test set predictions
testPreds <- predict(textFit, testDTM, type = 'class')

# Evaluate (in real life you don't know actuals right away)
confusionMatrix(as.factor(testPreds),
                as.factor(testDiabetesTxt$readmitted))
# End
