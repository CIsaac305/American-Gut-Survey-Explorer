# American-Gut-Survey-Explorer
Interactive R Shiny application for exploring and visualizing American Gut Project survey data from NCBI BioSample.

Live application: https://cisaac30.shinyapps.io/American-Gut-Survey-Explorer/

## Project Overview

This project uses R to retrieve and analyze publicly accessible biological survey information. Users can select BioSample records, examine survey responses, visualize participant age distributions, and download results as an Excel workbook.

## Technologies Used

- R and Shiny: Interactive application development

- rvest: Web scraping and HTML table extraction

- tidyverse: Data cleaning, manipulation, and visualization

- ggplot2: Age-distribution plots

- writexl: Excel data export

## Key Features

Retrieve survey information from NCBI BioSample records.

Process a list of 29 BioSample accession identifiers.

Clean and combine survey data.

Visualize participant age categories.

Export retrieved survey tables to Excel.

## Running the Application

1. Install R and RStudio.

2. Download the repository files.

3. Install the required packages:

install.packages(c("shiny", "rvest", "tidyverse", "writexl"))

4. Keep app.R and ExcludeNightshadesAccessionList.txt in the same folder.

5. Run:

shiny::runApp()

An internet connection is required to retrieve NCBI BioSample records.

## Repository Files

- `app.R` — R Shiny application source code.

- `ExcludeNightshadesAccessionList.txt` — BioSample accession identifiers.

- `README.md` — Project documentation.

## Limitations

The application retrieves data through web scraping, so changes to the NCBI website may affect functionality. The age visualization also depends on the availability and format of age-category information in the source records.

## Data Source

NCBI BioSample
