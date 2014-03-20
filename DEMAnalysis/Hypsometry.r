## R script for ploting altitudinal area distributions
## Takayuki NUIMURA 2014-03-20


t <- proc.time()


## <preamble>

library(rgdal)
library(raster)

## </preamble>



## <parameter>

cellsize <- 90
elevation.bin <- 200
elevation.range <- range(2100, 7900) ## Odds hundred does not allowed
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

## Calculate histogram breaks
hist.breaks <- seq(elevation.range[1] - elevation.bin, elevation.range[2] + elevation.bin, elevation.bin)

## Calculate count of each bin
h <- hist(mask.r, breaks=hist.breaks, plot=FALSE)

## Label of each bin
hist.mid <- h$mids

## Delete label except each 1000 m a.s.l.
hist.mid[hist.mid%%1000!=0] <- NA


## Unit conversion (number of grids (90 m grid) >> km^2)
elevation.hist <- h$counts * (cellsize^2 / (1000 * 1000))

## Adjust plot position
par(mar=c(5.1, 5.1, 4.1, 2.1))

barplot(elevation.hist,
        horiz=T,
        names.arg=hist.mid, las=1,
        space=0, border=F, col="lightblue",
        xlim=c(0, 1000), cex.axis=1.2,
        xlab=expression(paste("Area (", km^2, ")", sep="")), cex.lab=1.2, cex=1.2)
mtext("Elevation (m a.s.l.)", side=2, cex=1.2, line=4)

abline(v=0, lwd=1)
legend("bottomright", legend="Area",
       cex=1.2, fill="lightblue", bty="n")

## </processing>
    
print(proc.time() - t)

# rm(list=ls())
