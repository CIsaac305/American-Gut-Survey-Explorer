library(shiny)
library(rvest)
library(tidyverse)
library(writexl)

accessions <- readLines("ExcludeNightshadesAccessionList.txt")

accessions <- trimws(accessions)
accessions <- accessions[accessions != ""]

length(accessions)

make_url <- function(accession) {
  
  paste0("https://www.ncbi.nlm.nih.gov/biosample/?term=", accession)
  
}

scrape_biosample <- function(accession) {
  
  url <- make_url(accession)
  
  page <- read_html(url)
  
  survey_table <- page |>
    html_elements("table") |>
    html_table()
  
  survey_table <- survey_table[[1]]
  
  survey_table <- survey_table |>
    rename(
      Question = X1,
      Response = X2
    )
  
  return(survey_table)
  
}
ui <- fluidPage(
  
  titlePanel("American Gut Survey Explorer"),
  p(
    "Explore American Gut Project survey data from NCBI BioSample records. 
   Select the number of individuals, retrieve their survey responses,
   visualize demographic information, and download the results to Excel."
  ),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId = "num_samples",
        label = "Number of individuals:",
        min = 1,
        max = length(accessions),
        value = 5,
        step = 1,
        ticks = FALSE
      ),
      actionButton(
        inputId = "scrape",
        label = "Scrape Surveys"
      )
    ),

    mainPanel(
      
      h3("American Gut Survey Data"),
      
      textOutput("scrape_status"),
      
      tableOutput("survey_preview"),
      
      downloadButton(
        outputId = "download_surveys",
        label = "Download Surveys to Excel"
      ),
      
      plotOutput("age_plot")
      
    )
  )
)     
# Define server logic required to draw a histogram
server <- function(input, output) {
  
  surveys <- eventReactive(input$scrape, {
    
    selected_ids <- accessions[1:input$num_samples]
    
    survey_list <- withProgress(
      message = "Scraping American Gut Surveys...",
      value = 0,
      {
        
        results <- vector("list", length(selected_ids))
        
        for (i in seq_along(selected_ids)) {
          
          results[[i]] <- scrape_biosample(selected_ids[i])
          
          incProgress(
            1 / length(selected_ids),
            detail = paste("Survey", i, "of", length(selected_ids))
          )
          
        }
        
        results
        
      }
    )
    
    names(survey_list) <- selected_ids
    
    return(survey_list)
    
  })
  output$scrape_status <- renderText({
    
    paste("Successfully scraped", length(surveys()), "surveys.")
    
  })
  output$survey_preview <- renderTable({
    
    req(surveys())
    
    head(surveys()[[1]], 10)
    
  })
  output$download_surveys <- downloadHandler(
    
    filename = function() {
      "American_Gut_Surveys.xlsx"
    },
    
    content = function(file) {
      req(surveys())
      write_xlsx(surveys(), path = file)
    }
    
  )
  output$age_plot <- renderPlot({
    
    req(surveys())
    
    combined_surveys <- bind_rows(
      surveys(),
      .id = "BioSample_ID"
    )
    print(
      combined_surveys |>
        filter(str_detect(Question, "age"))
    )
    
    age_data <- combined_surveys |>
      filter(Question %in% c("age cat", "age_cat")) |>
      mutate(
        Response = factor(
          Response,
          levels = c("10s", "20s", "30s", "40s",
                     "50s", "60s", "70s", "80s",
                     "90s", "100+")
        )
      )
    ggplot(age_data, aes(x = Response)) +
      geom_bar(fill = "steelblue") +
      scale_y_continuous(
        breaks = function(limits) {
          seq(0, ceiling(limits[2]), by = 1)
        }
      ) +
      labs(
        title = "Age Distribution of American Gut Participants",
        subtitle = "Based on selected BioSample survey responses",
        x = "Age Category",
        y = "Number of Individuals"
      ) +
      theme_minimal()
    
  })
}
# Run the application 
shinyApp(ui = ui, server = server)
