
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