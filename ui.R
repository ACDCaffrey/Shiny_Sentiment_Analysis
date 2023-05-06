ui <- fluidPage(

    titlePanel("Sentiment Analysis"),
    p("Only 100 entries will be analysed - you can updated this behaviour in the server file if needed"),

    sidebarLayout(position = "right",
        sidebarPanel(
          fileInput("input_file", "Load data", accept = ".csv"),
          selectInput("column_select", 
                      label = "Select Field", 
                      choices = c(""),
                      multiple = FALSE)
        ),

        # Show a plot of the generated distribution
        mainPanel(
          tabsetPanel(
            tabPanel("raw data", br(), shinycssloaders::withSpinner(DT::dataTableOutput("raw_data"))),
            tabPanel("wordcloud", 
              shinycssloaders::withSpinner(
              wordcloud2Output("wordcloud"))
              ),
            tabPanel("sentiment analysis", shinycssloaders::withSpinner(
                     DT::dataTableOutput("sentiment")
                     ))
          )
        )
    )
)


