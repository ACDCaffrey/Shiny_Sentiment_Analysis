library(shiny)
library(DT)
library(dplyr)
library(magrittr)

library(wordcloud2)
library(tidytext)
library(tm)

library(shinycssloaders)

set.seed(1234)

options(shiny.maxRequestSize=250*1024^2) # 250 Mb

# TODO:
# csv load in data (single column)
# display data
# sentiment analysis
# word frequency
# wordcloud
