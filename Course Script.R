## Course Notes
## Developing Data Products - JHU Coursera
## July 2019
## Khalil H Najafi
##
## ABSTRACT:
## Rough script file containing code examples and exercises

# # # # # # # # # #

###### FUNCTIONS & WORKSPACE ######
# REQUIRED LIBRARIES
libraries <- c("data.table", "tidyverse", "lubridate", "shiny", "miniUI")
lapply(libraries, require, character.only = T)
rm(libraries)



# # # # # # # # # #



#### CODE EXAMPLES ####

#### Gadget - Mini UI Example ####
require(shiny)
require(miniUI)

mini_UI_example <- function(n1, n2) {

        # Still require UI and server Shiny objects
        ui <- miniPage(
                gadgetTitleBar("Mini & Useful on Mobile"),
                p("This is what text looks like on a mini page Shiny App",
                  "Here is an input gadget:"),
                miniContentPanel(
                        p("Within this panel we'll demonstrate inputs"),
                        #Input arguments are defined in the parent function above
                        selectInput("n01", "Choose your first number:", n1),
                        selectInput("n02", "Choose your second number:", n2)
                )

        )

        server <- function(input, output, session) {
                # A button, with JS event to close upon click
                # We can take the inputs from the UI within `observeEvent`
                observeEvent(input$done, {
                        num01 <- as.integer(input$n01)
                        num02 <- as.integer(input$n02)

                        # And transform within `StopApp`
                        stopApp(num01 * num02)
                })
        }

        # Compiling app
        runGadget(ui, server)
}
