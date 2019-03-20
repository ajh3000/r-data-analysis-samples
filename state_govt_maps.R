install.packages("raster")
install.packages("rgdal")
install.packages("broom")
install.packages("utf8")
install.packages("ggmap")
install.packages("maptools")
install.packages("mapproj")

library(readr)
library(ggplot2)
library(maps)
library(ggthemes)
library(ggmap)

library(rgeos)
library(sp)
library(raster)
library(rgdal)
library(maptools)
library(mapproj)
library(broom)

# Required for accessing Google Maps API
google_api_key <- "insert api key here"

shapefile_location <- "/path/to/your/shapefile"

# must run for every new session to access Google Maps
register_google(key = google_api_key)


shp <- shapefile(shapefile_location)

shp0 <- spTransform(shp, CRS("+proj=longlat +datum=WGS84"))
data <- fortify(shp)

head(tidy(shp))

#map <- get_map(location = "Melbourne, Australia", source="google", zoom = 13)

map <- get_googlemap( center = c(lon = 144.9631, lat = -37.8136), zoom = 9, maptype = "terrain",
                      path = "&style=feature:all|element:labels|visibility:on")

# plot(shp)
# 
# plot(data)

# this uses shp as the polygon data source
ggmap(map, extent = "normal", maprange = FALSE) +
  geom_polygon(data = shp,
               aes(long, lat, group = group, fill = id),
               colour = "red", alpha = 0.2) + 
  guides(fill = FALSE) +
  coord_map(projection="mercator",
            xlim=c(attr(map, "bb")$ll.lon, attr(map, "bb")$ur.lon),
            ylim=c(attr(map, "bb")$ll.lat, attr(map, "bb")$ur.lat))



data0 <- fortify(shp, region ="DISTRICT")
# data0 <- tidy(shp, region = "DISTRICT")

# over(data0)

# this uses data0 which has been "fortified"
ggmap(map, extent = "normal", maprange = FALSE) +
  geom_polygon(data = data0,
               aes(long, lat, group = group, fill = id),
               colour = "red", alpha = 0.2) + 
  guides(fill = FALSE) +
  coord_map(projection="mercator",
            xlim=c(attr(map, "bb")$ll.lon, attr(map, "bb")$ur.lon),
            ylim=c(attr(map, "bb")$ll.lat, attr(map, "bb")$ur.lat))



id <- rownames(shp@data)
district <- shp@data$DISTRICT
districtc <- shp@data$DISTRICTC

district.labels <- data.frame(id, district, districtc)


# mapa <- readOGR(dsn=".",layer="shapefile name w/o .shp extension")
map@data$id <- rownames(mapa@data)
mapa@data   <- join(mapa@data, data, by="CD_GEOCODI")
mapa.df     <- fortify(mapa)
mapa.df     <- join(mapa.df,mapa@data, by="id")



ggplot(data = shp) +
  geom_polygon(aes(long, lat, group = group, fill = id), colour = "red", alpha = 0.2)

