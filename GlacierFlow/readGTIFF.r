## R function for reading geotiff file.
## Takayuki NUIMURA 2010


readGTIFF <- function(...) {
  cat("<READGTIFF>\n")

  
  ## <preamble>

  library(rgdal)
  
  ## </preamble>

  
  ## <preprocessing>

  arg.list <- list(...)
  narg <- length(arg.list)

  ## </preprocessing>

  
  ## <processing>
  
  gtiff.filename <- arg.list[1]
  cat("Input geotiff: ", as.character(gtiff.filename), "\n")
  
  switch(as.character(narg),
         "1" = {
           cat("Whole range reading mode\n")
           
           frame.obj <- readGDAL(gtiff.filename, silent=TRUE)
         },
         "5" = {
           cat("Subsetted range reading mode\n")

           ## User specified geotiff range.
           west <- as.numeric(arg.list[2])
           south <- as.numeric(arg.list[3])
           east <- as.numeric(arg.list[4])
           north <- as.numeric(arg.list[5])


           gtiff.obj <- readGDAL(gtiff.filename, silent=TRUE)
           
           ## Original geotiff range.
           gtiff.west <- gtiff.obj@bbox[1]
           gtiff.south <- gtiff.obj@bbox[2]
           gtiff.east <- gtiff.obj@bbox[3]
           gtiff.north <- gtiff.obj@bbox[4]
           
           gtiff.width <- gtiff.obj@grid@cells.dim[1]
           gtiff.height <- gtiff.obj@grid@cells.dim[2]
           
           cellsize <- gtiff.obj@grid@cellsize[1]

           ## Class "data" , 1 dimension vector, needs to convert matrix.
           org.griddata <- matrix(gtiff.obj@data[,1], c(gtiff.width, gtiff.height))
           org.griddata <- t(org.griddata)
           
           
           ## Align to cell size
           frame.west <- round(west / cellsize) * cellsize
           frame.south <- round(south / cellsize) * cellsize
           frame.east <- round(east / cellsize) * cellsize
           frame.north <- round(north / cellsize) * cellsize

           frame.width <- (frame.east - frame.west) / cellsize
           frame.height <- (frame.north - frame.south) / cellsize
           

           grid.frame <- matrix(NA, frame.width, frame.height)
           grid.frame <- t(grid.frame)

           ## Offset between original and specified gtiff range in each direction.
           ## Offset value is not geographic distance but matrix index number.
           xmin.offset <- abs(frame.west - gtiff.west) / cellsize
           ymax.offset <- abs(frame.south - gtiff.south) / cellsize
           xmax.offset <- abs(frame.east - gtiff.east) / cellsize
           ymin.offset <- abs(frame.north - gtiff.north) / cellsize
           
           ## Default index range of frame
           frame.xmin <- 1
           frame.ymax <- frame.height
           frame.xmax <- frame.width
           frame.ymin <- 1

           ## Default index range of gtiff
           gtiff.xmin <- 1 + xmin.offset
           gtiff.ymax <- gtiff.height - ymax.offset
           gtiff.ymin <- 1 + ymin.offset
           gtiff.xmax <- gtiff.width - xmax.offset


           ## If specified range is larger than gtiff range, extend the gtiff data as NA value.
           if(frame.west < gtiff.west) {
             cat("Outside of data range to west is filled with NA'\n")
             frame.xmin <- 1 + xmin.offset
             gtiff.xmin <- 1
           }

           if(frame.south < gtiff.south) {
             cat("Outside of data range to south is filled with NA'\n")
             frame.ymax  <- frame.height - ymax.offset
             gtiff.ymax <- gtiff.height
           }

           if(frame.east > gtiff.east) {
             cat("Outside of data range to east is filled with NA'\n")
             frame.xmax <- frame.width - xmax.offset
             gtiff.xmax <- gtiff.width
           }

           if(frame.north > gtiff.north) {
             cat("Outside of data range to north is filled with NA'\n")
             frame.ymin <- 1 + ymin.offset
             gtiff.ymin <- 1
           }

           if(frame.west >= gtiff.west && frame.south >= gtiff.south && frame.east <= gtiff.east && frame.north <= gtiff.north) {
             cat("Data range covers whole frame range\n")
           }

           ## Most important process in this function.
           
           grid.frame[frame.ymin:frame.ymax, frame.xmin:frame.xmax] <- org.griddata[gtiff.ymin: gtiff.ymax, gtiff.xmin:gtiff.xmax]

           frame.grid.topology <- GridTopology(c(frame.west + cellsize / 2, frame.south + cellsize / 2), c(cellsize, cellsize), c(frame.width, frame.height))

           frame.data <- data.frame(band1=as.vector(t(grid.frame)), row.names=NULL)
           
           frame.obj <- SpatialGridDataFrame(frame.grid.topology, frame.data, gtiff.obj@proj4string)


         },
         cat("Invalid argument number\n")
         
         )
  ## </processing>

  cat("</READGTIFF>\n\n")

  return(frame.obj)
}



