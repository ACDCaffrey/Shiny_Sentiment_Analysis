library(tidytext)
library(textdata)
library(dplyr)
library(magrittr)

# load data
bing <- get_sentiments("bing")
afinn <- get_sentiments("afinn")

# convert to +ve and -ve
my_bing <- 
  bing %>% 
  mutate(new_val = case_when(sentiment == "negative" ~ -1,
                             sentiment == "positive" ~ 1,
                             .default = 0)) %>% 
  filter(new_val != 0) %>% 
  select(-sentiment)

my_afinn <- 
  afinn %>% 
  mutate(new_val = case_when(value > 0 ~ 1,
                             value < 0 ~ -1,
                             .default = 0)) %>% 
  filter(new_val != 0) %>% 
  select(-value)

# combine and remove duplicates
my_lexicon <- 
  rbind(my_bing, my_afinn) %>% unique

# remove further duplicates
duplicates <- my_lexicon %>% select(word) %>% duplicated()
duplicated_words <- my_lexicon[duplicates == TRUE,] # display

# remove all versions, re-add negative
my_lexicon %<>% 
  filter(!(word %in% duplicated_words$word))

duplicated_words$new_val <- -1
my_lexicon <- rbind(my_lexicon, duplicated_words)

# rename and save
names(my_lexicon) <- c("word", "value")

write.csv(my_lexicon,
          file = "./my_lexicon.csv", 
          row.names = FALSE)


#