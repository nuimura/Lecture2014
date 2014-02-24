#!/bin/bash
# Converting polygon (ex. glacier area) to raster.
# Takayuki NUIMURA 2011


echo -e "<POLYGON2RASTER>\n"



#<parameter>

## Glacier mask
POLYGON_FILEPATH=glacier.shp

CELLSIZE=2.5


ATTRIBUTE="value"
DATATYPE="Int16"

#</parameter>


#<preprocessing>

polygon_filename=$(basename ${POLYGON_FILEPATH})

## Output
raster_filepath=${polygon_filename%.shp}_grid${CELLSIZE}.tif

#</preprocessing>


#<processing>

gdal_rasterize ${POLYGON_FILEPATH} ${raster_filepath} -l ${polygon_filename%.shp} -ot ${DATATYPE} -a_nodata ${nodata} -a ${ATTRIBUTE} -tr ${CELLSIZE} ${CELLSIZE} -tap

#</processing>


echo -e "<POLYGON2RASTER>\n\n"

