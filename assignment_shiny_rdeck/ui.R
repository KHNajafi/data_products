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
library("shiny")
library("tidyverse")
library("data.table")
library("lubridate")
library("leaflet")
library("directlabels")


# # # # # # # # # #


###### DATASETS ######
dat_shelter <- fread("./dataset_toronto-shelter-20190806.csv")
dat_shelter_mth <- fread("./dataset_toronto-shelter-monthly-20190806.csv")

## Variable Types
dat_shelter <- dat_shelter %>%
    mutate(OCCUPANCY_DATE = ymd(OCCUPANCY_DATE),
           latitude = as.numeric(latitude),
           longitude = as.numeric(longitude))

dat_shelter_mth <- dat_shelter_mth %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude)) %>%
    arrange(desc(capacity_mean))


# # # # # # # # # #


###### UI COMPONENTS ######
txt_header <- p(br(),
                "How does occupancy in city shelters compare through the year?",
                br(),
                "Select a date to see occupancy across shelters.",
                "The radius reflects average monthly capacity",
                "and optionally you can filter by group.")

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
    titlePanel("Toronto — An Exploration of Homelessness in the City"),
    h6("Khalil H Najafi | www.khnajafi.me"),


    # Sidebar with 1) date input, and 2) sector selection for data displayed
    sidebarLayout(
        sidebarPanel(

            # Date Input: select the month
            dateInput("date",
                      "Select Date:",
                      value = "2019-04-26",
                      min = min(dat_shelter$OCCUPANCY_DATE),
                      max = max(dat_shelter$OCCUPANCY_DATE)),


            # Sector Input: select the sectors to display
            checkboxGroupInput("sectors",
                               "Groups to Show:",
                               choices = c("Co-ed",
                                           "Families",
                                           "Men",
                                           "Women",
                                           "Youth"),
                               selected = c("Families"))
            ),


        # Main display: tabs with preamble and main analytics
        mainPanel(

            tabsetPanel(type = "tabs",

                        tabPanel("About",
                                 txt_about
                                 ),

                        tabPanel("Shelter Occupancy",
                                 txt_header,

                                 h4("Map of Shelters & Capacities"),
                                 htmlOutput("map_header"),
                                 ## Shelter Occupancy Map
                                 leafletOutput("map_shelters"),

                                 hr(),

                                 ## Occupancy Summary Text
                                 htmlOutput("text_summary"),
                                 br(),

                                 ## Occupancy Time Series
                                 h4("Facility Occupancy by Day"),
                                 plotOutput("facility_occupancy")))
        )
    )
))
