# Odum_Feb_23

Repository for Odum Short course

Natural Language Processing (NLP) is the art and science of extracting insights from large amounts of text. The course topics will help students add NLP methods to their research, and data science toolset. As a technical course with some machine learning elements, limited exposure to programming, and graduate-level statistics is needed but the vast majority of the course content will be focused on applications and examples. Students will learn how to implement a variety of popular text mining methods in R (a free and open-source software) to organize, and process text aimed at identifying insights, extracting frequent terms and assessing sentiment analysis.

The following introduction to R video will aid students new to R programming.  **In addition, the video demonstrates how to clone the course git repository.  Students are *highly* encouraged to clone the repository and ensure all packages are installed correctly.**

## Tentative Schedule

|Date|12-1pm|1-2pm|2-2:30pm|
|------|-------------------------|-------------------|-------------------------------|
|Feb6  | Setup? What is NLP?     | Basic Strings     | Pre-Processing Term Frequency |
|Feb8  | Frequency & Association | Word Clouds       | Word Clouds & Pyramids        |
|Feb10 | Sentiment & Polarity    | Doc Classification| Technology ML Ethics          |

## R Packages for Installation

```
# Individually you can use 
# install.packages('packageName') such as below:
install.packages('ggplot2')

# or 
install.packages('pacman')
pacman::p_load(caret, corpus, dplyr, echarts4r, ggplot2, ggthemes, glmnet, hunspell,
               lexicon, magrittr, mgsub, pbapply, plotrix, qdap, rbokeh, RColorBrewer,                   sentimentr, spelling, stringi, stringr, text2vec, textdata,
               tidyr, tidytext, tm, wordcloud)

```

### If you're on a Mac, sometimes `library(qdap)` will fail due to an rJava issue.  If so, these resources can help.

For most students these three links have helped them install java, and then make sure R/Rstudio can find it when loading qdap.  **Keep in mind, you *have* to install qdap** This is more for use of some functions and the `polarity()` function and string manipulation.

* [link1](https://zhiyzuo.github.io/installation-rJava/)
* [link2](https://stackoverflow.com/questions/63830621/installing-rjava-on-macos-catalina-10-15-6)

Once java is installed this command *from terminal* often resolves the issue:
```
sudo R CMD javareconf
```