
server <- function(input, output, session) {
  
  
  # load data into reactive method
  data_input <- reactive({
    req(input$input_file)
    read.csv(input$input_file$datapath)
  })
  
  # render data table
  output$raw_data <- DT::renderDataTable({
    
    req(data_input())
    
    data <- data_input() %>% 
      select(input$column_select)
    
    if(length(input$column_select) != 0){
      datatable(data, 
                options = list(scrollX=TRUE)) 
    }
  })
  
  observeEvent(data_input(),{
    updateSelectInput(session, "column_select", choices = names(data_input()))
  })
  
  output$wordcloud <- renderWordcloud2({
    
    if(length(input$column_select) == 1){
    
      data <- 
        data_input() %>% 
        select(Positive_Review) %>% 
        VectorSource() %>% 
        Corpus() %>% 
        tm_map(removeNumbers) %>% 
        tm_map(removePunctuation) %>% 
        tm_map(stripWhitespace) %>% 
        tm_map(removeWords, c(stopwords("english"), "the"))
        
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
  
  # render selection for columns
  # output$column_select <- renderUI({
  #   
  #   req(data)
  # 
  #   selectInput("column", 
  #               label = "Select Columns", 
  #               choices = names(data))
  #   
  # })
  
}