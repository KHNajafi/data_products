## Toronto Shelter Occupancy
## Developing Data Products - JHU Coursera
## August 2019
## Khalil H Najafi
##
## ABSTRACT:
## Homelessness is a major urban issue, what do occupancies for shelters look like in Toronto


# # # # # # # # # #


###### FUNCTIONS & WORKSPACE ######
# REQUIRED LIBRARIES
libraries <- c("shiny", "data.table", "tidyverse", "lubridate", "leaflet")
lapply(libraries, require, character.only = T)
rm(libraries)


# # # # # # # # # #


###### DATASETS ######
dat_shelter <- fread("./dataset_toronto-shelter-20190806.csv")

dat_shelter_mth <- fread("./dataset_toronto-shelter-monthly-20190806.csv")


# # # # # # # # # #


###### UI COMPONENTS ######
txt_header <- p(br(),
                "How does occupancy in city shelters compare through the year?",
                br(),
                "Select a date to see occupancy across shelters.",
                "The radius reflects capacity and optionally you can filter by sector.")

txt_about <- p(br(),
               "Homelessness is a byproduct of socioeconomic systems, ",
               "and is most apparent in large urban cities.  In my home city of Toronto, ",
               "there are over 40 organizations that operate temporary housing and ",
               "emergency shelters in coordination with the city.",
               br(), br(),
               "Many of us see some of those affected by homelessness in our day to day life ",
               "but are largely unaware of these programs.  To help shine a light on this ",
               "aspect of city life, we can look at data on some of the shelter programs ",
               "across the city.  To help in the effort to end homelessness, we can start ",
               "asking questions from the data such as: ",
               br(), br(),
               strong("Which groups are most affected by homelessness?"),
               br(),
               strong("How does occupancy and availability change over the year?"),
               br(),
               strong("What areas of the city are shelters operating?"),
               br(), br(),
               "The ", code("Daily Shelter Occupancy"),
               " dataset is from Toronto's Open Data program, available online at ",
               "https://open.toronto.ca")



###### UI BUILD ######
# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Toronto Shelter Capacities"),
    h6("Khalil H Najafi | www.khnajafi.me"),


    # Sidebar with 1) date input, and 2) sector selection for data displayed
    sidebarLayout(
        sidebarPanel(

            # Date Input: select the month
            dateInput("date",
                      "Select Date:",
                      value = "2019-03-01",
                      min = "2019-01-01",
                      max = "2019-08-06"),


            # Sector Input: select the sectors to display
            checkboxGroupInput("sectors",
                               "Groups to Show:",
                               choices = c("Co-ed",
                                           "Families",
                                           "Men",
                                           "Women",
                                           "Youth"),
                               selected = c("Families")),


            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),


        # Main display: tabs with preamble and main analytics
        mainPanel(

            tabsetPanel(type = "tabs",

                        tabPanel("About",
                                 txt_about
                                 ),

                        tabPanel("Shelter Analytics",
                                 txt_header,
                                 plotOutput("distPlot")))
        )
    )
))
