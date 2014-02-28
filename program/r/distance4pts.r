## R script for adding distance value to Shapefile attribute table.
## Takayuki NUIMURA 2012


t <- proc.time()

## <preamble>

library(foreign)

## </preamble>


## <parameter>

## Input as full path
pt.shp.filepath <- "glacier_profile_seg100_pt.shp"

## Points interval
seg <- 100

## </parameter>


## <preprocessing>

pt.dbf.filepath <- sub(".shp", ".dbf", pt.shp.filepath)

## </preprocessing>


## <processing>

work.data <- read.dbf(pt.dbf.filepath)

work.data$dist <- numeric(nrow(work.data))

for (i in unique(work.data[,1])) {
    print(i)
    n.row <- nrow(work.data[work.data[,1] == i, ])

    work.data[work.data[,1] == i, 2] <- seq(from=0, by=seg, length=n.row)
}

work.data[,1] <- as.integer(work.data[,1])
work.data[,2] <- as.integer(work.data[,2])

## </processing>


## <output>

write.dbf(work.data, pt.dbf.filepath)

## </output>


print(proc.time() - t)

rm(list=ls())
