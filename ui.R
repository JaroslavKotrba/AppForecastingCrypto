# Libraries
library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)

# ui
ui <- fluidPage(
  tags$head(tags$link(rel="shortcut icon", href="https://cutewallpaper.org/24/bitcoin-png/hd-blue-btc-bitcoin-crypto-blockchain-coin-icon-png-citypng.png")),
  title = "Crypto Currencies",
  titlePanel("Crypto Currencies"),
  br(),
  p("See crypto currencies prices, select the one you are interested in from the box below!"),
  
  sidebarLayout(
    
    sidebarPanel(
      selectInput(
        inputId = "select_coin",
        label = "Select crypto currency:",
        choices = c("BTC-USD", "ETH-USD", "CRO-USD"),
        selected = "BTC-USD"
      ),
      
      dateRangeInput(
        inputId = "date",
        label = "Select date:",
        start = "2020-01-01", 
        end = as.character(Sys.Date())
      ),
      
      numericInput(
        inputId = "periods",
        label = "Select number of forecasted days:",
        value = 90,
        min = 0, max = 365, step = 5
      ),
      
      selectInput(
        inputId = "breaks",
        label = "Select date breaks:",
        choices = c("1 month", "4 months", "6 months", "12 months"),
        selected = "6 months"
      )
    ),
    
    mainPanel(
      
      # Title of the graph
      verbatimTextOutput("name"),
      
      plotlyOutput("coin"), # plotly
    )
  ),
  
  p("\n"),
  uiOutput("link1", style="padding-left: 0px"),
  uiOutput("link2", style="padding-left: 0px")
)