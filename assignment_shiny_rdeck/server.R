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

# FUNCTIONS
colour_pal <- function(sector_length = 1) {
    if (sector_length == 1) {
        return(c("#cbd5e8"))

    }

    if (sector_length == 2) {
        return(c("#b3e2cd", "#e6f5c9"))

    }

    if (sector_length == 3) {
        return(c("#b3e2cd", "#cbd5e8", "#e6f5c9"))

    }

    if (sector_length == 4) {
        return(c("#b3e2cd", "#fdcdac", "#f4cae4", "#e6f5c9"))

    }

    if (sector_length == 5) {
        return(c("#b3e2cd", "#fdcdac", "#cbd5e8", "#f4cae4", "#e6f5c9"))

    }
}


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


###### SERVER LOGIC FOR APP ######
shinyServer(function(input, output) {


    #### Map Header (map_header) ####
    output$map_header <- renderText({

        dates_mtht <- lubridate::month(input$date, label = T, abbr = F)
        sec       <- paste(input$sectors, collapse = ", ")

        paste("Location and average capacity in", em(dates_mtht))
    })



    #### Shelter Map (map_shelters) ####
    output$map_shelters <- renderLeaflet({

        dates     <- input$date
        dates_mth <- month(input$date)
        sec       <- input$sectors
        dat       <- dat_shelter_mth %>%
            filter(occupancy_month == dates_mth,
                   SECTOR %in% sec)


        # Colours for Sectors
        sector_pal <- colorFactor(c("#b3e2cd", "#fdcdac", "#cbd5e8", "#f4cae4", "#e6f5c9"),
                                  dat$SECTOR)

        maps <- leaflet(dat) %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addCircles(weight = 3,
                       lat = ~latitude,
                       lng = ~longitude,
                       radius = ~sqrt(capacity_mean) * 100,
                       color = ~sector_pal(SECTOR),
                       opacity = 1,
                       fillOpacity = 0.15,
                       popup = paste0(dat$FACILITY_NAME,
                                      "<br>Sector: ",
                                      dat$SECTOR,
                                      "<br>",
                                      lubridate::month(dates, label = T, abbr = F),
                                      ", Avg Capacity [Avg Occupancy]:",
                                      "<br>",
                                      round(dat$capacity_mean),
                                      " [",
                                      round(dat$occupancy_rate_mean * 100, 1),
                                      "%]")) %>%
            addLegend("bottomright",
                      pal = sector_pal,
                      values = ~SECTOR,
                      title = "Groups",
                      opacity = 1)

        maps
    })




    #### Summary Text Output (text_summary) ####
    output$text_summary <- renderText({


        # Input Values
        dates      <- input$date
        dates_mth  <- month(input$date)
        dates_mtht <- lubridate::month(input$date, label = T, abbr = F)
        sec        <- input$sectors
        dat        <- dat_shelter %>%
            filter(occupancy_month == dates_mth,
                   OCCUPANCY_DATE <= dates,
                   SECTOR %in% sec)


        # No groups selected message
        if (nrow(dat) == 0) {

            paste("Select at least one group to see a time series of facility occupancy",
                  "for", dates_mtht, "through to", dates_mtht, day(dates), "below")

        }



        # Max occupancy rate, facility, and sector
        else {

            occupancy_max     <- round(max(dat$occupancy_rate) * 100, 1)
            occupancy_max_fac <- dat %>%
                arrange(desc(occupancy_rate)) %>%
                select(FACILITY_NAME) %>%
                head(1) %>%
                as.character()
            occupancy_max_sec <- dat %>%
                arrange(desc(occupancy_rate)) %>%
                select(SECTOR) %>%
                head(1) %>%
                as.character()

            paste0("For the month until ", strong(dates_mtht), " ", strong(day(dates)),
                   " of the groups selected, occupancy peaked at ",
                   strong(occupancy_max), strong("%"), ", at the facility: ",
                   em(occupancy_max_fac), "; a shelter for ", occupancy_max_sec)

        }


    })



    #### Facility Occupancy Time Series (facility_occupancy) ####
    output$facility_occupancy <- renderPlot({


        # Input Values
        dates      <- input$date
        dates_mth  <- month(input$date)
        dates_mtht <- lubridate::month(input$date, label = T, abbr = F)
        sec        <- input$sectors
        dat        <- dat_shelter %>%
            filter(occupancy_month == dates_mth,
                   OCCUPANCY_DATE <= dates,
                   SECTOR %in% sec)


        ###  Visualization Parameters
        # Number of Facilities for line-series
        reps <- length(unique(dat$FACILITY_NAME))

        # Colour aesthetics to match group inputs & map colour
        colour <- colour_pal(length(sec))

        ### Occupancy Time Series Visualization
        ggplot(dat, aes(OCCUPANCY_DATE, occupancy_rate)) +
            geom_line(aes(linetype = FACILITY_NAME, colour = SECTOR)) +
            geom_point(size = 1, aes(colour = SECTOR)) +
            geom_dl(aes(label = FACILITY_NAME,
                        color = SECTOR),
                    method = list(cex = 0.7, "top.bumpup")) +
            scale_linetype_manual(values = rep("solid", reps),
                                  guide = "none") +
            scale_colour_manual(values = colour) +
            scale_y_continuous(labels = scales::percent) +
            theme_bw() +
            theme(legend.position = "bottom") +
            labs(x = "",
                 y = "Occupancy",
                 colour = "",
                 linetype = "Facility")
    })

})





