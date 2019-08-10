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



#### Assignment - Shiny App w/ Pitch Deck ####
## For this assignment continuing with Toronto's Open Data
## Shiny app:
##      will highlight shelter occupancy for YTD 2019
##      by "sector" (families, mens, womens)
## Pitch deck:
##      5 slides in slidify or Rstudio presenter
##      hosted on GitHub pages or Rpubs
##      link to Shiny app
##      contain some R code to be executed upon knitting


#### >> Shiny App ####

#### >>>>> Dataset Creation ####
#### +-------> Raw Dataset Download (URL Method) ####

require(jsonlite)
url_dataset <- "https://ckan0.cf.opendata.inter.prod-toronto.ca/download_resource/e4cdcaff-7c06-488a-a072-4880fbd84b88"
dat_shelter_raw <- fromJSON(url_dataset, simplifyDataFrame = T)


#### +-------> Shelter Address & Coordinates ####
shelter_address <- dat_shelter_raw %>%
        distinct(FACILITY_NAME)

shelter_latlong <- data.frame(latitude = c("43.77076",
                                           "43.77076",
                                    "43.77030",
                                    "43.65789",
                                    "43.66586",
                                    "43.66586",
                                    "43.66517",
                                    "43.76860",
                                    "43.76860",
                                    "43.76860",
                                    "43.74247",
                                    "43.76074",
                                    "43.76074",
                                    "43.76074",
                                    "43.72786",
                                    "43.76074",
                                    "43.64182",
                                    "43.64182",
                                    "43.66048",
                                    "43.69159",
                                    "43.65970",
                                    "43.65970",
                                    "43.64874",
                                    "43.66155",
                                    "43.64792",
                                    "43.65185",
                                    "43.69192",
                                    "43.65950",
                                    "43.65994",
                                    "43.68911",
                                    "43.65983",
                                    "43.64649",
                                    "43.76334",
                                    "43.77280",
                                    "43.65021",
                                    "43.66719",
                                    "43.66763",
                                    "43.65910",
                                    "43.65208",
                                    "43.71563",
                                    NA,
                                    "43.65618",
                                    "43.72784",
                                    "43.65838",
                                    "43.71729",
                                    "43.64086",
                                    "43.68920",
                                    "43.69077",
                                    "43.68145",
                                    "43.68187",
                                    "43.65831",
                                    "43.66254",
                                    "43.61795",
                                    "43.65998",
                                    "43.79812",
                                    "43.67208",
                                    "43.65929",
                                    "43.65453",
                                    "43.65453",
                                    "43.65453",
                                    "43.66554",
                                    "43.64649",
                                    "43.65221",
                                    "43.65518",
                                    "43.66202",
                                    "43.73920",
                                    "43.73920",
                                    "43.65864",
                                    "43.67350",
                                    "43.67350",
                                    "43.66581",
                                    "43.65201",
                                    "43.67237",
                                    "43.64879",
                                    "43.66791",
                                    "43.68466",
                                    "43.68466",
                                    "43.73630",
                                    "43.73630",
                                    "43.65185",
                                    "43.67530",
                                    "43.67530",
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    NA,
                                    "43.63673",
                                    "43.63673",
                                    "43.73420",
                                    "43.71752",
                                    "43.63673"),
                       longitude = c("-79.33630",
                                     "-79.33630",
                                     "-79.32300",
                                     "-79.40709",
                                     "-79.44592",
                                     "-79.44592",
                                     "-79.41886",
                                     "-79.26737",
                                     "-79.26737",
                                     "-79.26737",
                                     "-79.49655",
                                     "-79.19677",
                                     "-79.19677",
                                     "-79.19677",
                                     "-79.22889",
                                     "-79.19677",
                                     "-79.40197",
                                     "-79.40197",
                                     "-79.37171",
                                     "-79.26423",
                                     "-79.37432",
                                     "-79.37432",
                                     "-79.39314",
                                     "-79.37880",
                                     "-79.41147",
                                     "-79.40363",
                                     "-79.43987",
                                     "-79.38144",
                                     "-79.38127",
                                     "-79.29815",
                                     "-79.37427",
                                     "-79.39824",
                                     "-79.36092",
                                     "-79.41475",
                                     "-79.40167",
                                     "-79.37484",
                                     "-79.37925",
                                     "-79.36817",
                                     "-79.37435",
                                     "-79.46741",
                                     NA,
                                     "-79.36248",
                                     "-79.26629",
                                     "-79.44324",
                                     "-79.25874",
                                     "-79.41024",
                                     "-79.46211",
                                     "-79.34950",
                                     "-79.41820",
                                     "-79.41870",
                                     "-79.40866",
                                     "-79.33820",
                                     "-79.49736",
                                     "-79.37838",
                                     "-79.39510",
                                     "-79.37373",
                                     "-79.37273",
                                     "-79.36685",
                                     "-79.36685",
                                     "-79.36685",
                                     "-79.46313",
                                     "-79.40630",
                                     "-79.37252",
                                     "-79.36922",
                                     "-79.32949",
                                     "-79.56568",
                                     "-79.56568",
                                     "-79.40079",
                                     "-79.40638",
                                     "-79.40638",
                                     "-79.37921",
                                     "-79.39139",
                                     "-79.32216",
                                     "-79.39843",
                                     "-79.40554",
                                     "-79.38926",
                                     "-79.38926",
                                     "-79.58083",
                                     "-79.58083",
                                     "-79.40363",
                                     "-79.40152",
                                     "-79.40152",
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     NA,
                                     "-79.39782",
                                     "-79.39782",
                                     "-79.22253",
                                     "-79.28313",
                                     "-79.39782"))

dat_shelter_coord <- cbind(shelter_address, shelter_latlong) %>%
        # Remove facilities with missing coordinates (will be excluded)
        filter(!is.na(latitude))




#### +-------> Dataset Creation - Main Table ####
dat_shelter <- dat_shelter_raw %>%
        # Merge in lat/long coordinates for facilities
        left_join(dat_shelter_coord) %>%
        # Remove facilities with no coordinate data (cannot map)
        filter(!is.na(latitude)) %>%
        # Remove observations with 0/missing capacity
        filter(!is.na(CAPACITY) & CAPACITY > 0) %>%
        # Create Variables
        #       year, month, occupancy rate
        mutate(OCCUPANCY_DATE = ymd(OCCUPANCY_DATE),
               occupancy_year = year(OCCUPANCY_DATE),
               occupancy_month = month(OCCUPANCY_DATE),
               occupancy_rate = OCCUPANCY/CAPACITY) %>%
        select(ORGANIZATION_NAME,
               SHELTER_NAME,
               PROGRAM_NAME,
               SECTOR,
               FACILITY_NAME,
               OCCUPANCY_DATE,
               CAPACITY,
               OCCUPANCY,
               occupancy_rate,
               latitude,
               longitude,
               SHELTER_ADDRESS,
               SHELTER_CITY,
               SHELTER_POSTAL_CODE,
               SHELTER_PROVINCE,
               occupancy_year,
               occupancy_month) %>%
        arrange(OCCUPANCY_DATE)




#### +-------> Dataset Creation - Monthly Summary Table ####
dat_shelter_mth <- dat_shelter %>%
        # Summarise by Facility, Year, Month
        group_by(SHELTER_NAME,
                 SECTOR,
                 FACILITY_NAME,
                 latitude,
                 longitude,
                 occupancy_year,
                 occupancy_month) %>%
        summarise(capacity_mean = mean(CAPACITY),
                  occupancy_rate_mean = mean(occupancy_rate)) %>%
        select(SHELTER_NAME,
               SECTOR,
               FACILITY_NAME,
               occupancy_year,
               occupancy_month,
               capacity_mean,
               occupancy_rate_mean,
               latitude,
               longitude)


## Export Datasets

write.table(dat_shelter,
            "./assignment_shiny_rdeck/dataset_toronto-shelter-20190806.csv",
            sep = ",",
            row.names = F)

write.table(dat_shelter_mth,
            "./assignment_shiny_rdeck/dataset_toronto-shelter-monthly-20190806.csv",
            sep = ",",
            row.names = F)





