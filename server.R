
server <- function(input, output, session) {
  
  
  # load data into reactive method
  data_input <- reactive({
    req(input$input_file)
    read.csv(input$input_file$datapath, nrows = 100) # edit lines loaded
  })
  
  # render data table
  output$raw_data <- DT::renderDataTable({
    
    req(data_input())
    if(is.na(input$column_select)) return();
    
    data <- data_input() %>% 
      select(input$column_select)
    
    if(length(input$column_select) != 0){
      datatable(data, 
                options = list(scrollX=TRUE,
                               options = list(pageLength = 100))) 
    }
  })
  
  observeEvent(data_input(),{
    updateSelectInput(session, "column_select", choices = names(data_input()))
  })
  
  output$wordcloud <- renderWordcloud2({
    
    req(data_input())
    
    if(length(input$column_select) == 1){
    
      data <- 
        data_input() %>% 
        select(Positive_Review) %>% 
        VectorSource() %>% 
        Corpus() %>% 
        tm_map(removeNumbers) %>% 
        tm_map(removePunctuation) %>% 
        tm_map(removeWords, c(stopwords("english"), "the", "can")) %>% 
        tm_map(stripWhitespace)
        
      data_matrix <- data %>% 
        TermDocumentMatrix() %>% 
        as.matrix() %>% 
        rowSums() %>% 
        sort(decreasing = TRUE)
      
      data_df <- 
        data_matrix %>% 
        data.frame(word = names(.), freq = .)
      
      wordcloud2(data = data_df)
      
    }
    
  })
  
  output_table <- reactive({

    req(data_input())
    
    data_list <- data_input() %>% 
      select(input$column_select) %>% 
      split(., seq(nrow(.)))
    
    series <- tibble()
    raw <- data_input() %>% select(input$column_select)
    
    for(i in 1:nrow(raw)) {
      
      clean <- tibble(num = i,
                      text = data_list[[i]][[1]]) %>%
        unnest_tokens(word, 
                      text,
                      token = stringr::str_split,
                      pattern = "[./!?\" ]") %>% # text must be character
        select(everything()) %>% 
        filter(word != "")
      
      series <- rbind(series, clean)
      
    }
    
    series_sentiment <- 
      series %>% 
      left_join(my_words, 
                by = join_by(word == word)) 

    # negations ----------------------------------------------------------------
    
    # look for negation words, if following word is within the same response,
    # then multiply the value by -1
    
    # row of negated words
    negation_indexes <- which(series_sentiment$word %in% negation_words == TRUE) 
    
    # question number where negations are found
    negation_questions <- series_sentiment[negation_indexes,]$num
    
    # question number for word after negation
    negation_next_position <- series_sentiment[negation_indexes+1,]$num
    
    # indexes to flip
    indexes_to_flip <- negation_indexes[negation_questions == negation_next_position]+1
    
    # where the numbers match, flip the value
    series_sentiment$value[indexes_to_flip] <- series_sentiment$value[indexes_to_flip]*-1
    
    # "very"
    negation_next_next_position <- series_sentiment[negation_indexes+2,]$num
    # 2 words after negators, are they part of the same question, if so return ids
    allowed_updates <- negation_indexes[negation_questions == negation_next_next_position] 
    
    negation_next_word <- series_sentiment[allowed_updates+1,]$word # words following negation
    
    preceding_flip_word <- negation_indexes[negation_next_word == "very"] # whose which are "very
    
    series_sentiment$value[preceding_flip_word+2] <- series_sentiment$value[preceding_flip_word+2]*-1 # flip sign
    
    # end of negations 
    
    # highlighting words -------------------------------------------------------
    
    if(input$highlight == TRUE){
      series_sentiment %<>% 
        mutate(replacement_word = case_when(
          value == -1 ~ paste0(negative_highlight, word, "</span>"),
          value ==  1 ~ paste0(positive_highlight, word, "</span>"),
          .default = word
        ))
      
      series_sentiment$output <- series_sentiment$replacement_word
    
    } else{
      series_sentiment$output <- series_sentiment$word
    }
    
    # end of highlighting
    
    series_compiled <- 
      series_sentiment %>% 
      group_by(num) %>% 
      summarize(score = sum(value, na.rm = T),
                output_text = str_flatten(output, " ")) %>% 
      ungroup() %>% 
      select(-num) 

  })
  
  output$sentiment <- renderDataTable(output_table(), 
                                      escape = FALSE, options = list(dom = "ilt", 
                                                                     pageLength = 100))
  
}