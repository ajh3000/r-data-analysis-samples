install.packages("readr")
install.packages("rgeos")

install.packages("raster")
install.packages("rgdal")
install.packages("broom")
install.packages("ggmap")
install.packages("rgeos")
install.packages("sp")

install.packages("bigquery")

library(bigrquery)
library(readr)

library(raster)
library(rgdal)
library(broom)
library(ggmap)
library(rgeos)
library(sp)

# Google Cloud project ID 
project <- "insert google project name" 
dataset <- "insert big query dataset"
table_address <- paste(project, dataset, sep = ".")
shp_location <- "insert local shape file location"

sql <- paste("
SELECT
b.StopLocationID,
b.GPSLat,
b.GPSLong
FROM
`", table_address, ".StopLocationsFull` b
WHERE
b.GPSLat IS NOT NULL AND
b.GPSLong IS NOT NULL 
ORDER BY
b.StopLocationID
", sep = "")

ScanLocations <- query_exec(sql, project = project, use_legacy_sql = FALSE)

ScanLocationsCoords <- ScanLocations

shp <- shapefile(shp_location)

data0 <- fortify(shp, region ="DISTRICT")
# data0 <- tidy(shp, region = "DISTRICT")

# make a spatial object
coordinates(ScanLocationsCoords) <- ~GPSLong+GPSLat

# GDA94 <- CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
GDA94 <- CRS("+proj=longlat +ellps=GRS80 +no_defs")

# use correct projection GDA94
StopPoints <- SpatialPoints(ScanLocationsCoords, proj4string = GDA94)


# using over, left outer join the StopPoints with the polygons of the shp file
a.data <- over(StopPoints, shp[,"DISTRICT"])

# StopPoints$district <- a.data$DISTRICT

AnnotatedStopLocations <- ScanLocations

AnnotatedStopLocations$Electorate <- a.data$DISTRICT


crs(shp)
shp$area_sqkm <- area(shp) / 1000000

insert_upload_job(project, dataset, "electorates", AnnotatedStopLocations)


ElectorateAreas <- data.frame(shp$area_sqkm, shp$DISTRICT)
names(ElectorateAreas)[1] <- "area_sqkm"
names(ElectorateAreas)[2] <- "district"

insert_upload_job(project, dataset, "electorateAreas", ElectorateAreas)



                         