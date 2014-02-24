#!/bin/bash
# Grass script must be called by grass terminal (started as "grass -text" command)
# Converting line to point Shapefile
# Takayuki NUIMURA 2012


echo -e "<LINE2PT>\n"


#<parameter>

## Specify your data directory
WORK_DIR="/work"

# Input file
SHP_LINE_FILENAME=*.shp

## Interval of generated points
SEGMENT=100

#</parameter>


#<preprocessing>

# Output
shp_pt_filename=${SHP_LINE_FILENAME%.shp}_seg${SEGMENT}_pt.shp

start_dir=$(pwd)

#</preprocessing>


#<processing>

cd ${WORK_DIR}

v.in.ogr --q dsn=${SHP_LINE_FILENAME} output=tmp_v1 --o
g.region --q -a vect=tmp_v1

v.to.points --q input=tmp_v1 output=tmp_v2 type=line dmax=${SEGMENT} --o

v.out.ogr --q -c input=tmp_v2 type=point dsn=${shp_pt_filename} format="ESRI_Shapefile" -s

g.mremove -f vect=tmp_v*

cd ${start_dir}

#</processing>

echo -e "</LINE2PT>\n\n"

