#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(rgdal)
library(dplyr)

# Define UI for application that draws a scatterplot
ui <- fluidPage(
   
   # Application title
   titlePanel("Plot of GPS Collar Test Data"),
   
   # Sidebar with a slider input for confidence ellipse width
   sidebarLayout(
      sidebarPanel(
        fileInput("csvfile", "Choose CSV File",
                  accept=c("text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv")),
        hr(),
        sliderInput("conf",
                     "Confidence ellipse width:",
                     min = 50,
                     max = 100,
                     value = 90)
      ),
      
      # Show a plot of the GPS data
      mainPanel(
         plotOutput("gpsPlot")
      )
   )
)

# Define server logic required to draw scatterplot
server <- function(input, output) {
  
   output$gpsPlot <- renderPlot({
      
      # Get the uploaded file name
      csvfile <- input$csvfile 
      if (is.null(csvfile)) # Avoid error before we have a file uploaded.
        return(NULL)
     
      print(csvfile$datapath)
      # load the data
      gps.data <- read.csv(csvfile$datapath, header=T, stringsAsFactors = F) 
      
      # Reproject data to UTM projection
      coordinates(gps.data) <- ~Lon+Lat
      proj4string(gps.data) <- CRS("+proj=longlat +datum=WGS84")
      gps.data.u11 <- spTransform(gps.data, CRS=CRS("+proj=utm +zone=11 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
      
      # Calc difference from average coordinates
      meanLat <- mean(gps.data.u11$Lat)
      meanLon <- mean(gps.data.u11$Lon)
      sdLat <- sd(gps.data.u11$Lat)
      sdLon <- sd(gps.data.u11$Lon)
      
      gps.data.u11$diffLat <- meanLat - gps.data.u11$Lat
      gps.data.u11$diffLon <- meanLon - gps.data.u11$Lon
      gps.data.u11$diffdist <- sqrt(gps.data.u11$diffLat^2+gps.data.u11$diffLon^2)
      
      # Plot the data
      plot.df <- data.frame(gps.data.u11)
      g <- ggplot(data=plot.df, aes(x=diffLon,y=diffLat,color=HDOP))+geom_point() +
        scale_color_gradient2(low="#006837", mid="#fee08b", high="#a50026", midpoint=200) +
        stat_ellipse(level=input$conf/100)+geom_hline(yintercept = 0) + geom_vline(xintercept = 0) #+
        labs(title="GPS positional error", x="Difference from Avg Longitude (m)", y="Difference from Avg Latitude (m)")
      g

   })
}

# Run the application 
shinyApp(ui = ui, server = server)

