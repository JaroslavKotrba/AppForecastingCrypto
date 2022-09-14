# server
server <- function(input, output) {
  options(scipen = 999)
  
  output$name <- renderText({ 
    
    NAME <- function(name){
      if (name == 'BTC-USD'){
        return('Bitcoin (USD)')
      }
      else if (name == 'ETH-USD'){
        return('Ethereum (USD)')
      }
      else if (name == 'CRO-USD'){
        return('Cronos (USD)')
      }}
    
    NAME(input$select_coin)
  })
  
  output$coin <- renderPlotly({
    
    # Data
    library(tseries)
    df <- get.hist.quote(instrument = input$select_coin,
                         start = input$date[1],
                         end = input$date[2],
                         quote = "Close",
                         compression = "d")
    
    # df <- get.hist.quote(instrument = "BTC-USD",
    #                      start = "2018-01-01",
    #                      end = Sys.Date(),
    #                      quote = "Close",
    #                      compression = "d")
    
    df <- data.frame(df)
    df$ds <- as.Date(as.character(row.names(df)))
    colnames(df)[which(names(df) == "Close")] <- "y"
    
    row.names(df) <- seq(1, length(df$ds), 1)
    df <- subset(df, select = c(ds, y))
    
    # Model
    library(prophet)
    model <- prophet(yearly.seasonality = T,
                     weekly.seasonality = F,
                     daily.seasonality = F,
                     seasonality.mode = 'multiplicative', # or additive
                     seasonality.prior.scale = 10, # strength of the seasonality
                     holidays.prior.scale = 10, # weight of the holidays
                     changepoint.prior.scale = 0.05) # keeping trend robust
    model <- fit.prophet(model, df)
    
    future <- make_future_dataframe(model, periods = input$periods)
    
    # Forecast
    forecast <- predict(model, future)
    forecast <- forecast[c('ds', 'yhat')]
    
    library(tidyverse)
    df_forecast <- full_join(df, forecast, by=c("ds"))
    df_forecast$color <- ifelse(is.na(df_forecast$y), 1, 0)
    df_forecast$y <- ifelse(is.na(df_forecast$y), df_forecast$yhat, df_forecast$y)
    df_forecast$ds <- as.Date(as.character(df_forecast$ds))
    
    library(ggplot2)
    library(plotly)
    g <- ggplot(data = df_forecast, aes(x=ds, y=y, color=color)) +
      geom_line(lwd=0.5, aes(text = paste0("Date: ", as.Date(..x.., origin = "1970-01-01"),
                                           "<br>Price: ", round(..y.., 2), " USD"))) +
      geom_smooth(col="red", lwd=0.5, se=FALSE, linetype = "dashed", aes(text = paste0("Date: ", as.Date(..x.., origin = "1970-01-01"),
                                                                                       "<br>Price: ", round(..y.., 2), " USD"))) +
      geom_vline(xintercept=as.numeric(as.Date(Sys.Date())), lwd=0.3, linetype=4) +
      xlab("Time") +
      ylab("Price") +
      scale_x_date(date_labels = "%Y-%b", date_breaks = input$breaks) +
      theme_bw() +
      theme(legend.position="none")
    
    g <- ggplotly(g, tooltip = c("text"))
  })
  
  url1 <- a("https://finance.yahoo.com", href="https://finance.yahoo.com")
  output$link1 <- renderUI({
    tagList("Source:", url1)
  })
  
  url2 <- a("https://jaroslavkotrba.com", href="https://jaroslavkotrba.com")
  output$link2 <- renderUI({
    tagList("Other projects:", url2)
  })
}