
install.packages("bigrquery")
install.packages("ggplot2")
install.packages("maps")
install.packages("ggthemes")
install.packages("ggmap")
install.packages("dplyr")
install.packages("readr")

library(readr)
library(bigrquery)
library(ggplot2)
library(maps)
library(ggthemes)
library(ggmap)
library(dplyr)

# source(file = "parameters.R")

# Required for accessing Google Maps API
google_api_key <- "insert api key here"

# Google Cloud project ID 
project <- "insert project ID here" 

dataset <- "insert data set name here"


# must run for every new session to access Google Maps
register_google(key = google_api_key)

table_address <- paste(project, dataset, sep = ".")

# Get ScanOn transactions and locations first, for two hours in 2018
sql <- paste("
SELECT
COUNT(*) AS ScanOnCount,
b.StopNameLong,
b.GPSLat,
b.GPSLong
FROM `", table_address,
  ".ScanOnTransactions` a
LEFT OUTER JOIN `", table_address,
  ".StopLocations` b 
ON
a.StopID = b.StopLocationID
WHERE
DateTime > '2018-02-07 07:00:00'
AND DateTime < '2018-02-07 09:00:00'
AND Mode = 2
GROUP BY
b.StopNameLong,
b.GPSLat,
b.GPSLong
ORDER BY
COUNT(*) DESC", sep = ""
)

scanons_trains_7til9 <- query_exec(sql, project = project, use_legacy_sql = FALSE)

# Get car traffic observations and locations second
sql <- paste("
SELECT
location_index,
lat AS GPSLat,
lon AS GPSLong,
meanWed7,
meanWed8,
sdWed7,
sdWed8
FROM
`", table_address, ".VehicleTraffic0`
ORDER BY
meanWed7,
meanWed8 DESC", sep = ""
)

road_traffic_7til9 <- query_exec(sql, project = project, use_legacy_sql = FALSE)


road_traffic_7til9_1 <- road_traffic_7til9 %>% filter(meanWed7 < 22 
                                                      & meanWed7 > 0 
                                                      & meanWed8 < 22 
                                                      & meanWed8 > 0)


myMap <- get_googlemap( center = c(lon = 144.9631, lat = -37.8136), zoom = 11, maptype = "terrain",
                        path = "&style=feature:all|element:labels|visibility:on")


# Plot the data points from "scanon" and "traffic" on the map, for two hours in 2018
ggmap(myMap) + 
  geom_point(data = scanons_trains_7til9[, c("GPSLong","GPSLat", "ScanOnCount")], 
             aes(x=GPSLong, y = GPSLat, size = ScanOnCount, alpha = .3),
             colour = "blue") +
  geom_point(data = road_traffic_7til9_1[, c("GPSLong","GPSLat", "meanWed7", "meanWed8")], 
             aes(x=GPSLong, y = GPSLat, size = -meanWed8),
             colour = "red") +
  scale_size_continuous(range = c(1, 8), guide = FALSE) 



