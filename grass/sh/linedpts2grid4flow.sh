#!/bin/bash
# Grass script must be called by grass terminal (started as "grass -text" command)
# Converting longitudinal allined points to grid
# Takayuki NUIMURA 2012


echo -e "<LINEDPTS2GRID4FLOW>\n"


#<parameter>

# Input files in full path
SHP_PT_FILEPATH=glacier_profile_seg100_pt.shp
GTIFF_MASK_FILEPATH=glacier_area_grid2.5.tif

cellsize=2.5

#</parameter>


#<preprocessing>

work_dir=$(dirname ${SHP_PT_FILEPATH})
shp_pt_filename=$(basename ${SHP_PT_FILEPATH})
gtiff_mask_filename=$(basename ${GTIFF_MASK_FILEPATH})


# Output
distgrid_filename=${shp_pt_filename%.shp}_dist${cellsize}.tif
directgrid_filename=${shp_pt_filename%.shp}_direct${cellsize}.tif


start_dir=$(pwd)

#</preprocessing>


#<processing>

cd ${work_dir}

v.in.ogr --q dsn=${shp_pt_filename} output=tmp_v1 -z --o
r.in.gdal -o -e input=${gtiff_mask_filename} output=MASK 

cellsize=$(r.info -s MASK | grep "nsres" | cut -d= -f2)

g.region --q -a rast=MASK res=${cellsize}

v.surf.rst input=tmp_v1 elev=tmp_r1 layer=1 zcolumn=${dist}

r.out.gdal input=tmp_r1 format=GTiff type=Int16 output=${distgrid_filename} nodata=-9999 -c

cd ${start_dir}

#</processing>

echo -e "</LINEDPTS2GRID4FLOW>\n\n"

