 ## R script for converting diff to annual scalar (m / a) after adjusting.
## Takayuki NUIMURA 2012

t <- proc.time()

## <preamble>

library(rgdal)

## </preamble>


## <subfunction>

source("readGTIFF.r")

## </subfunction>


## <parameter>

## Input
gtiff.filename <- "disp20081024_20101203.tif"
gl.area.filename <- "lirung_gl_area_extended_grid2.5.tif"


duration <- 2.1
cellsize <- 2.5

## Threshold values
corr.th <- 0.6
outlier.th <- 100
magnitude.th <- 6

## </parameter>


## <preprocessing>

rootname <- sub(".tif", "", gtiff.filename)

## </preprocessing>

## Reading target extent information
target <- GDALinfo(gtiff.filename)
w <- target["ll.x"]
s <- target["ll.y"]
e <- target["ll.x"] + target["columns"] * target["res.x"]
n <- target["ll.y"] + target["rows"] * target["res.y"]


gl.area.obj <- readGTIFF(gl.area.filename, w, s, e, n)
gl.area <- gl.area.obj$band1


    ## for (i in 3) { ## DEBUG
    rootname <- as.character(rootname)
    cat("Processing: ", rootname, "\n")


    ## <processing>

    ## Input
    disp.filename <- paste(rootname, ".tif", sep="")

    ## Output
    disp.summary.filename <- paste(rootname, "_summary.csv", sep="")
    disp.x.filename <- paste(rootname, "_x", cellsize, ".tif", sep="")
    disp.y.filename <- paste(rootname, "_y", cellsize, ".tif", sep="")
    corr.filename <- paste(rootname, "_corr", cellsize, ".tif", sep="")
    scalar.filename <- paste(rootname, "_scalar", cellsize, ".tif", sep="")
    direct.filename <- paste(rootname, "_direct", cellsize, ".tif", sep="")

    ## Skip processed scene
    if (file.exists(disp.x.filename)) {
        cat(disp.filename, " has already been processed! \n")
    } else if (!file.exists(disp.filename)) {
        ## Skip unprepared scene
        cat(disp.filename, " has not yet been prepared! \n")
    } else {

        disp.x.obj <- readGDAL(disp.filename, band=1)
        disp.y.obj <- readGDAL(disp.filename, band=2)
        corr.obj <- readGDAL(disp.filename, band=3)
        scalar.obj <- disp.x.obj #Recycling object
        direct.obj <- disp.x.obj #Recycling object

        disp.x <- disp.x.obj$band1## * cellsize
        disp.y <- disp.y.obj$band1## * cellsize
        corr <- corr.obj$band1

        ## Normalize duration to annual
        disp.x <- disp.x / duration
        disp.y <- disp.y / duration

        ## Correlation filter
        disp.x[corr < corr.th] <- NA
        disp.y[corr < corr.th] <- NA

        ## Separation for on and off glacier
        disp.x.bedrock <- disp.x
        disp.y.bedrock <- disp.y
        disp.x.glacier <- disp.x
        disp.y.glacier <- disp.y
        disp.x.bedrock[!is.na(gl.area)] <- NA
        disp.y.bedrock[!is.na(gl.area)] <- NA
        disp.x.glacier[is.na(gl.area)] <- NA
        disp.y.glacier[is.na(gl.area)] <- NA


        ## Static summary before calibration
        disp.x.bedrock.median <- median(disp.x.bedrock, na.rm=T)
        disp.y.bedrock.median <- median(disp.y.bedrock, na.rm=T)
        disp.x.bedrock.sd <- sd(disp.x.bedrock, na.rm=T)
        disp.y.bedrock.sd <- sd(disp.y.bedrock, na.rm=T)
        disp.x.glacier.median <- median(disp.x.glacier, na.rm=T)
        disp.y.glacier.median <- median(disp.y.glacier, na.rm=T)
        disp.x.glacier.sd <- sd(disp.x.glacier, na.rm=T)
        disp.y.glacier.sd <- sd(disp.y.glacier, na.rm=T)




        bias.x <- disp.x.bedrock.median
        bias.y <- disp.y.bedrock.median

        disp.x.bedrock <- disp.x.bedrock - bias.x
        disp.y.bedrock <- disp.y.bedrock - bias.y
        disp.x.glacier <- disp.x.glacier - bias.x
        disp.y.glacier <- disp.y.glacier - bias.y
        disp.x <- disp.x - bias.x
        disp.y <- disp.y - bias.y

        #Excluding outlier value.
        disp.x.bedrock[abs(disp.x.bedrock) > outlier.th] <- NA
        disp.y.bedrock[abs(disp.y.bedrock) > outlier.th] <- NA

        disp.x.bedrock.sd.calib <- sd(disp.x.bedrock, na.rm=T)
        disp.y.bedrock.sd.calib <- sd(disp.y.bedrock, na.rm=T)

        #Excluding anomaly value outside X sigma.
        disp.x.bedrock[abs(disp.x.bedrock) > disp.x.bedrock.sd.calib * magnitude.th] <- NA
        disp.y.bedrock[abs(disp.y.bedrock) > disp.y.bedrock.sd.calib * magnitude.th] <- NA
        disp.x.glacier[abs(disp.x.glacier) > disp.x.bedrock.sd.calib * magnitude.th] <- NA
        disp.y.glacier[abs(disp.y.glacier) > disp.y.bedrock.sd.calib * magnitude.th] <- NA
        disp.x[abs(disp.x) > disp.x.bedrock.sd.calib * magnitude.th] <- NA
        disp.y[abs(disp.y) > disp.y.bedrock.sd.calib * magnitude.th] <- NA

        ## Static summary after calibration
        disp.x.bedrock.median.calib <- median(disp.x.bedrock, na.rm=T)
        disp.y.bedrock.median.calib <- median(disp.y.bedrock, na.rm=T)
        disp.x.bedrock.sd.calib <- sd(disp.x.bedrock, na.rm=T)
        disp.y.bedrock.sd.calib <- sd(disp.y.bedrock, na.rm=T)
        disp.x.glacier.median.calib <- median(disp.x.glacier, na.rm=T)
        disp.y.glacier.median.calib <- median(disp.y.glacier, na.rm=T)
        disp.x.glacier.sd.calib <- sd(disp.x.glacier, na.rm=T)
        disp.y.glacier.sd.calib <- sd(disp.y.glacier, na.rm=T)

        stats.summary <- data.frame(
                         pre.calib <- c(
                                      disp.x.bedrock.median,
                                      disp.y.bedrock.median,
                                      disp.x.bedrock.sd,
                                      disp.y.bedrock.sd,
                                      disp.x.glacier.median,
                                      disp.y.glacier.median,
                                      disp.x.glacier.sd,
                                      disp.y.glacier.sd
                                      ),
                         post.calib <- c(
                                       disp.x.bedrock.median.calib,
                                       disp.y.bedrock.median.calib,
                                       disp.x.bedrock.sd.calib,
                                       disp.y.bedrock.sd.calib,
                                       disp.x.glacier.median.calib,
                                       disp.y.glacier.median.calib,
                                       disp.x.glacier.sd.calib,
                                       disp.y.glacier.sd.calib
                                       )
                         )
        colnames(stats.summary) <- c("pre.calib", "post.calib")
        rownames(stats.summary) <- c("x.bedrock.median", "y.bedrock.median", "x.bedrock.sd", "y.bedrock.sd", "x.glacier.median", "y.glacier.median", "x.glacier.sd", "y.glacier.sd")

        #Scalar calculation
        scalar <- sqrt(disp.x^2 + disp.y^2)

        ## Direction calculation
        direct <- atan2(disp.y, disp.x) / pi * 180


        disp.x[is.na(disp.x)] <- -9999
        disp.y[is.na(disp.y)] <- -9999
        corr[is.na(corr)] <- -9999
        scalar[is.na(scalar)] <- -9999
        direct[is.na(direct)] <- -9999

        disp.x.obj@data <- data.frame(band1=disp.x)
        disp.y.obj@data <- data.frame(band1=disp.y)
        corr.obj@data <- data.frame(band1=corr)
        scalar.obj@data <- data.frame(band1=scalar)
        direct.obj@data <- data.frame(band1=direct)

        ## </processing>


        ## <output>

        write.csv(stats.summary, disp.summary.filename)
        writeGDAL(disp.x.obj, disp.x.filename, mvFlag=-9999)
        writeGDAL(disp.y.obj, disp.y.filename, mvFlag=-9999)
        writeGDAL(corr.obj, corr.filename, mvFlag=-9999)
        writeGDAL(scalar.obj, scalar.filename, mvFlag=-9999)
        writeGDAL(direct.obj, direct.filename, mvFlag=-9999)

        ## </output>


    }


print(proc.time() - t)

## rm(list=ls())
