## Toronto Shelter Occupancy
## Developing Data Products - JHU Coursera
## August 2019
## Khalil H Najafi
##
##      This is the server script for the shelters analytics app
##      See ui.R for abstract


# # # # # # # # # #



###### FUNCTIONS & WORKSPACE ######
# REQUIRED LIBRARIES
libraries <- c("shiny", "data.table", "tidyverse", "lubridate", "leaflet")
lapply(libraries, require, character.only = T)
rm(libraries)


# # # # # # # # # #


###### SERVER LOGIC FOR APP ######
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })

})
