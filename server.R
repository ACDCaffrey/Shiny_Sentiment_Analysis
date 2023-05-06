
server <- function(input, output, session) {
  
  
  # load data into reactive method
  data_input <- reactive({
    req(input$input_file)
    read.csv(input$input_file$datapath, nrows = 100) 
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
        tm_map(removeWords, c(stopwords("english"), "the")) %>% 
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
  
  output$sentiment <- renderDataTable({

    req(data_input())
    
    data_list <- data_input() %>% 
      select(input$column_select) %>% 
      split(., seq(nrow(.)))
    
    series <- tibble()
    raw <- data_input() %>% select(input$column_select)
    
    for(i in 1:nrow(raw)) {
      
      clean <- tibble(num = i,
                      text = data_list[[i]][[1]]) %>%
        unnest_tokens(word, text) %>% # text must be character
        select(everything())
      
      series <- rbind(series, clean)
      
    }
    
    series_sentiment <- 
      series %>% 
      left_join(get_sentiments("afinn"), 
                by = join_by(word == word)) %>% 
      group_by(num) %>% 
      summarize(score = sum(value, na.rm = T)) %>% 
      ungroup() %>% 
      select(-num) %>% 
      cbind(raw, .) %>% 
      datatable(
        options = list(pageLength = 100)
      )
    


  })
  
}