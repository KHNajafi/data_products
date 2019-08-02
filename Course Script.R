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




#### Plotly Code Examples ####

#### >>>> Scatterplots ####
require(plotly)
# We do this to make it easier for plotly to infer properties of the vis
mtcars2 <- mtcars %>%
        mutate(vehicle = row.names(mtcars),
               cyl_f = as.factor(cyl))
plot_ly(mtcars, x = ~hp, y = ~disp, type = "scatter")
plot_ly(mtcars2, x = ~hp, y = ~disp, type = "scatter", color = ~cyl_f)
#3D scatter
plot_ly(mtcars2, x = ~disp, y = ~mpg, z = ~wt, type = "scatter3d", color = ~hp)
plot_ly(mtcars2, x = ~vehicle, y = ~hp, type = "bar", color = ~disp)


#### >>>> Lines ####
require(quantmod)
#Download stock price data for Apple `AAPL` for 2019 year-to-date
getSymbols("AAPL", src = "yahoo", from = date("2019-01-01"), to = date("2019-07-01"))
#Convert the timeseries into a dataframe
AAPL_data <- as.data.frame(AAPL) %>%
        as.tbl() %>%
        mutate(time = time(AAPL))

require(plotly)
plot_ly(AAPL_data, x = ~time, y = ~AAPL.Close, linetype = "dash")


#### >>>> Distributions ####

#### +-------> Histograms ####
plot_ly(AAPL_data, x = ~AAPL.High)


#### +-------> Box Plots ####
plot_ly(AAPL_data, y = ~AAPL.Open, type = "box")

#### +-------> Heatmaps & Surface (3D) ####
plot_ly(AAPL_data, x = ~AAPL.High, y = ~AAPL.Low, z = ~AAPL.Close, type = "surface")




#### Leaflet Code Examples ####
require(leaflet)

## Basic Map Code Examples

#Map canvas
maps <- leaflet() %>%
        addTiles()

# Toronto (Major) Sporting Venues
arenas <- data.frame(lat = c(43.64348,
                             43.6416,
                             43.63320,
                             43.66220),
                     lng = c(-79.37869,
                             -79.3892,
                             -79.41852,
                             -79.38030),
                     name = c("Place formerly known as the Air Canada Centre",
                              "Place really known as SkyDome",
                              "Only Reds I can tolerate",
                              "The last time I watched the Leafs"))
#VIS - Map
maps_sports <- maps %>%
        addMarkers(lat = arenas$lat,
                   lng = arenas$lng,
                   popup = arenas$name)

#custom markers
icon_sports <- makeIcon(
        iconUrl = "https://freepngimg.com/download/drake/10-2-drake-png-file.png",
        iconWidth = 80,
        iconHeight = 81,
        iconAnchorX = 80/2,
        iconAnchorY = 16)
#red maple leaf icon:
#https://cdn4.iconfinder.com/data/icons/flat-simple-canada/512/canada-02-512.png

#add hyperlinks to popup
arenas <- arenas %>%
        mutate(name_url = c("Place formerly known as the <a href='http://scotiabankarena.com'>Air Canada Centre</a>",
                         "Place really known as <a href='http://www.mlb.com/bluejays/ballpark'>SkyDome</a>",
                         "Only <a href='https://bmofield.com'>Reds</a> I can tolerate",
                         "The last time I watched the <a href='www.mattamyathleticcentre.ca/venue-info/arena-highlights-history'>Leafs</a>"))

#VIS - Map with Custom Icon & Links
maps_sports <- maps %>%
        addMarkers(lat = arenas$lat,
                   lng = arenas$lng,
                   icon = icon_sports,
                   popup = arenas$name_url)

#shapes on maps
arenas <- arenas %>%
        mutate(capacity = c(19800,
                            53506,
                            30000,
                            3850))

maps_sports %>%
        addCircles(weight = 1,
                   lat = arenas$lat,
                   lng = arenas$lng,
                   radius = sqrt(arenas$capacity) * 3,
                   popup = paste(arenas$name, ";<br>Capacity: ", arenas$capacity))




#### Toronto Open Data Snippet ####

#### >>>> Dataset Download - API Method ####
## The following was implemented directly from https://open.toronto.ca

require(httr)

# Get the dataset metadata by passing package_id to the package_search endpoint
# For example, to retrieve the metadata for this dataset:

response <- GET("https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show", query=list("id"="f816b362-778a-4480-b9ed-9b240e0fe9c2"))
package <- content(response, "parsed")
print(package)

# Get the data by passing the resource_id to the datastore_search endpoint
# See https://docs.ckan.org/en/latest/maintaining/datastore.html for detailed parameters options
# For example, to retrieve the data content for the first resource in the datastore:

for (resource in package$result$resources) {
        if (resource$datastore_active){
                r <- GET("https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/datastore_search", query=list("id"=resource$id))
                data <- content(r, "parsed")
                print(data)
                break
        }
}




#### +-------> Highrise Fire Inspections ####

# Upload dataset from file (.csv)
dat_fire <- fread("/Users/khnajafi/Downloads/Highrise Inspections Data.csv")

#variable transformation
dat_fire <- dat_fire %>%
        mutate(inspections.OpenedDate = ymd_hms(inspections.OpenedDate),
               Inspections.ClosedDate = ymd_hms(Inspections.ClosedDate),
               propertyAddress = as.factor(propertyAddress),
               propertyWard = as.factor(propertyWard))

## How do the number of inspections look over the time scale of the dataset?
## Are they steady, increasing, or decreasing?

dat_fire_monthly <- dat_fire %>%
        mutate(year = year(inspections.OpenedDate),
               month = month(inspections.OpenedDate)) %>%
        group_by(year, month) %>%
        tally() %>%
        group_by(year, month) %>%
        mutate(date = paste(c(year, month, "1"), collapse = "-"),
               date = ymd(date)) %>%
        select(year, month, date, n)

vis1 <- plot_ly(dat_fire_monthly,
                x = ~date,
                y = ~n,
                linetype = "dash") %>%
        layout(title = "Highrise Fire Safety Inspections Monthly",
               xaxis = list(title = "Date"),
               yaxis = list(title = "Total Monthly Inspections"))

plot_ly(as.data.frame(dat_fire_monthly), x = ~date, y = ~n, type = "scatter", mode = "lines")


## How do inspections look by ward?
## Are they typically clear?

dat_fire_ward <- dat_fire %>%
        mutate(inspections.IsClear = violations.violationFireCode == "",
               inspections.Value = ifelse(inspections.IsClear == T, 1, -1)) %>%
        group_by(propertyWard, inspections.IsClear) %>%
        summarise(value = sum(inspections.Value)) %>%
        group_by(propertyWard, inspections.IsClear) %>%
        mutate(text = ifelse(inspections.IsClear == T,
                             paste(c("Ward",
                                     propertyWard,
                                     "Clear Inspections:",
                                     value), collapse = " "),
                             paste(c("Ward",
                                     propertyWard,
                                     "Inspections with Violations:",
                                     abs(value)), collapse = " ")))

plot_ly(as.data.frame(dat_fire_ward),
        x = ~propertyWard,
        y = ~value,
        type = "bar",
        text = ~text,
        color = ~inspections.IsClear,
        colors = c("#ED3600", "#5CB85C")) %>%
        layout(showlegend = F,
               xaxis = list(title = "Ward Number"),
               yaxis = list(title = "Number of Inspections"))




