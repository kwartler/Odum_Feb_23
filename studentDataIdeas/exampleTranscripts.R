#' transcript example
#' https://bradlindblad.github.io/schrute/
# One needs to keep track of who is speaking so I suspect it's a lot of group_by
# or custom functions but here is a start using functions with grouping built in

# lib
library(schrute)
library(dplyr)
library(qdap)
library(tm)
data("theoffice")
dim(theoffice)

# Let's just look at the pilot
pilot <- subset(theoffice, theoffice$episode=='1')


head(pilot$text_w_direction) # has bracketed context of the speech
head(pilot$text) # same but w/o bracket context

# so let's just get word frequencies with functions that have gourping built in
charFreq <- wfm(text.var = pilot$text,
                grouping.var = pilot$character,
                output = "raw",
                stopwords = stopwords('english'))
charFreq <-as.data.frame(charFreq)

# Quick loop to get it done but its a bit cludgy
topTermsBySpeaker <- list()
for(i in 1:ncol(charFreq)){
  tmp <- subset(charFreq, charFreq[,i]>0)
  tmp <- tmp[order(tmp[,i], decreasing = T),]
  tmp <- data.frame(terms   = head(rownames(tmp)),
                    speaker = rep(colnames(tmp)[i],length(head(rownames(tmp)))),
                    freq    = head(tmp[,i]))
  topTermsBySpeaker[[i]] <- tmp
}
topTermsBySpeaker <- do.call(rbind, topTermsBySpeaker)
topTermsBySpeaker <- topTermsBySpeaker[order(topTermsBySpeaker$freq, decreasing = T),]
head(topTermsBySpeaker,10)
# End