install.packages("leaflet")
install.packages("tidyverse")
install.packages("rgdal")
library(tidyverse)
library(leaflet)
library(rgdal)

install.packages("tidycensus")
library(tidycensus)

census_api_key("96c814d684cf4c89bd22fa15d1cc26d9f098ddc8", overwrite = FALSE, install = TRUE)

#access cencus data 
m90 <- get_decennial(geography = "state", variables = "H043A001", year = 1990)

# chart our rent data 
m90 %>% 
  ggplot(aes(x=value, y=reorder(NAME, value))) +
  geom_point()

#get ACS data
transpo <- get_acs(geography = "state", variable = "B08006_008", geometry = FALSE, survey = "acs5", year = 2017)
transpo_total <- get_acs(geography = "state", variables = "B08006_001", geometry = FALSE, survey = "acs5", year = 2017)

#join our data
transpo <- transpo %>% left_join(transpo_total, by = "NAME")

#do our commuting share math
transpo$rate <- transpo$estimate.x / transpo$estimate.y * 100

# Map out
states <- readOGR("/Users/lisababyl/Desktop/JOUR 561 Data Journalism/tl_2019_us_state", 
                  layer = "tl_2019_us_state", GDAL1_integer64_policy = TRUE)

states_with_rate <- sp::merge(states, transpo, by = "NAME")

qpal <- colorQuantile("PiYG", states_with_rate$rate, 9)

states_with_rate %>% leaflet() %>% addTiles() %>%
  addPolygons(weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5,
              color = ~qpal(rate),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE))


