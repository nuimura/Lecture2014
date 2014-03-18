## R script for convertinf diff to scalar.
##
## Refactoring for Lirung.
## Replaced displacements (X and Y) to scalar.
## Takayuki NUIMURA 2012-08-21
##
## Takayuki NUIMURA 2011

t <- proc.time()

## <preamble>

library(rgdal)

## </preamble>


## <subfunction>

source("readGTIFF.r")

## </subfunction>


## <parameter>

cellsize <- 2.5

direct.filepath <- "disp20081024_20101203_direct2.5_screened_window51.tif"
scalar.filepath <- "disp20081024_20101203_scalar2.5_screened_window51.tif"

w <- 355800
s <- 3121800
e <- 360300
n <- 3129300


n.gtiff <- 4

## </parameter>


## <preprocessing>

ncols <- (e - w) / cellsize
nrows <- (n - s) / cellsize

## </preprocessing>


## <processing>

direct.obj <- readGTIFF(direct.filepath, w, s, e, n)
scalar.obj <- readGTIFF(scalar.filepath, w, s, e, n)


multi.grid <- matrix(NA, ncols * nrows, n.gtiff)
multi.grid[, 1] <- direct.obj@data[, 1]
multi.grid[, 2] <- scalar.obj@data[, 1]

multi.grid[,3:4] <- coordinates(scalar.obj)

## For GMT vector plot
vector.table <- na.omit(data.frame(x=multi.grid[,3], y=multi.grid[,4], direct=multi.grid[,1], scalar=multi.grid[,2]))


## </processing>


## <output>

write.csv(vector.table, file=paste("vector_data_", cellsize, ".csv", sep=""), row.names=F)

## </output>

print(proc.time() - t)

## rm(list=ls())
