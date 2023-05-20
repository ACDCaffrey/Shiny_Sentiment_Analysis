library(shiny)
library(DT)
library(dplyr)
library(magrittr)

library(wordcloud2)
library(tidytext)
library(tm)
library(stringr)

library(fuzzyjoin) # maybe
library(shinyWidgets)

library(shinycssloaders)

library(textdata)

set.seed(1234)

options(shiny.maxRequestSize=250*1024^2) # 250 Mb

my_words <- read.csv("./my_lexicon.csv")

negation_words <- c("not", "isn't", "wasn't")

positive_highlight <- "<span style='background-color:green;'>"
negative_highlight <- "<span style='background-color:red;'>"

#