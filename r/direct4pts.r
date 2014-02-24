## R script for adding direction value to Shapefile attribute table.
## Takayuki NUIMURA 2011


t <- proc.time()

## <preamble>

library(rgdal)

## </preamble>


## <parameter>

## Data directory as full path
work.dir <- "/work"

## Input data as full path
pt.shp.filename <- "glacier_profile_seg100_pt.shp"

## </parameter>


## <preprocessing>

pt.shp.filepath <- paste(work.dir, "/", pt.shp.filename, sep="")
pt.rootname <- sub(".shp", "", pt.shp.filename)

## </preprocessing>


## <processing>

work.data <- readOGR(pt.shp.filepath, layer=pt.rootname)

## Check attribute
if (ncol(work.data) > 2){
    cat("Direct attribute has been already appended!!\n")
    break
}

xy <- coordinates(work.data)[, -3]

work.data@data$direct <- numeric(nrow(work.data))
for (i in unique(work.data@data[,1 ])) {
    sub.xy <- xy[work.data@data[, 1] == i, ]

    ## Calculated direction is degree start from eastward (0) to both direction
    ## (to 180 in counter-clockwise, to -180 in clockwise).
    ## Di = atan2((Yi-1) - (Yi+1) , (Xi-1) - (Xi+1))
    ## Di: Direction at i, Yi: UTM Y coordinates at i, Xi: UTM X coordinates at i.
    direct <- atan2(-diff(sub.xy[, 2], lag=2), -diff(sub.xy[, 1], lag=2))/pi*180

    ## Both end points are extrapolated from innner next value.
    direct <- c(direct[1], direct, direct[length(direct)])

    work.data@data[work.data@data[, 1] == i, 3] <- direct
}

## </processing>


## <output>

writeOGR(work.data, pt.shp.filepath, layer=pt.rootname, driver="ESRI Shapefile")

## </output>


print(proc.time() - t)

rm(list=ls())
