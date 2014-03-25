## R script for ploting altitudinal area distributions as qumulative plot
## Takayuki NUIMURA 2014-03-25


t <- proc.time()


## <preamble>

library(rgdal)
library(raster)

## </preamble>



## <parameter>

cellsize <- 90
elevation.bin <- 200
elevation.range <- range(2100, 7900) 
crs <- CRS("+init=epsg:32645")

## Input
polygon.filepath <- "glacier.shp"
dem.filepath <- "gdem_mosaic_90m_subset.tif"

## </parameter>


## <processing>

## Reading Shapefile
v <- readOGR(polygon.filepath, sub(".shp", "", basename(polygon.filepath)), verbose=F)

## Reading GeoTIFF
r <- raster(dem.filepath)

## Rasterise polygon
vr <- rasterize(v, r)

## Clip raster based on rasterised polygon
mask.r <- mask(r, vr)

elevation <- sort(mask.r@data@values)

max.elevation <- max(elevation, na.rm=T)
min.elevation <- min(elevation, na.rm=T)
n.grid <- length(elevation)
total.area <- n.grid * (cellsize^2 / (1000 * 1000))

d <- data.frame(z=elevation, percent=((1:n.grid)/n.grid)* 100)

y2.labels <- seq(0, 2000, 500)

plot(d, las=1)
axis(side=4, at=(y2.labels / total.area) * 100, labels=y2.labels, cex.axis=1, las=1)
mtext("Area", side=4, line=4)




## </processing>
    
print(proc.time() - t)

# rm(list=ls())
