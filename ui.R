ui <- fluidPage(

    titlePanel("Sentiment Analysis"),

    sidebarLayout(position = "right",
        sidebarPanel(
          fileInput("input_file", "Load data", accept = ".csv"),
          selectInput("column_select", 
                      label = "Select Vars", 
                      choices = c(""),
                      multiple = TRUE)
        ),

        # Show a plot of the generated distribution
        mainPanel(
          tabsetPanel(
            tabPanel("raw data", br(), DT::dataTableOutput("raw_data")),
            tabPanel("wordcloud",),
            tabPanel("sentiment analysis", )
          )
        )
    )
)


