#!/bin/bash
# Grass script must be called by grass terminal (started as "grass -text" command)
# Screening surface displacement based on magnitude and direction
#
# Takayuki NUIMURA 2012-08-06


echo -e "<SCREENING_FLOW>\n"


#<parameter>

## Window size for filtering
window_list=(7)
# window_list=(7 19 37 51 73) ## If you prefer batch processing one by one

## Direction threshold
direction_th=60


#Input files as full path
## These files must have same grid size
MASK_GTIFF_FILEPATH=gl_area_grid2.5.tif
SCALAR_GTIFF_FILEPATH=disp20091202_20100117_scalar2.5.tif
DIRECT_GTIFF_FILEPATH=disp20091202_20100117_direct2.5.tif

#</parameter>


#<processing>

for window in ${window_list[@]}
do
    echo -e "Window size: "${window}

# Output
    screened_SCALAR_GTIFF_FILEPATH=${SCALAR_GTIFF_FILEPATH%.tif}_screened_window${window}.tif
    screened_DIRECT_GTIFF_FILEPATH=${DIRECT_GTIFF_FILEPATH%.tif}_screened_window${window}.tif
 
    
    r.in.gdal --q --o input=${SCALAR_GTIFF_FILEPATH} output=tmp_r1
    r.in.gdal --q --o input=${DIRECT_GTIFF_FILEPATH} output=tmp_r2
    r.in.gdal --q --o input=${MASK_GTIFF_FILEPATH} output=MASK

    g.region --q -a rast=MASK
    
    ## Magnitude filter (within median +/- 1 sigma)
    r.neighbors --o input=tmp_r1 output=tmp_r3 method=median size=${window}
    r.neighbors --o input=tmp_r1 output=tmp_r4 method=stddev size=${window}
    r.mapcalc "tmp_r5=if(tmp_r1 < tmp_r3 + tmp_r4 && tmp_r1 > tmp_r3 - tmp_r4, 1, null())"
    # If you change magnitude threshold. Please use following command (ex. case of 1.5 sigma).
    # r.mapcalc "tmp_r5=if(tmp_r1 < tmp_r3 + tmp_r4 * 1.5 && tmp_r1 > tmp_r3 - tmp_r4 * 1.5, 1, null())"
    
    ## Direction filter (within median +/- ${direction_th} degree)
    r.mapcalc tmp_x1="cos(tmp_r2)"
    r.mapcalc tmp_y1="sin(tmp_r2)"

    r.neighbors --o input=tmp_x1 output=tmp_x2 method=median size=${window}
    r.neighbors --o input=tmp_y1 output=tmp_y2 method=median size=${window}

    ## Reference angle
    r.mapcalc tmp_r6="atan(tmp_x2,tmp_y2)"

    ## Difference from refference angle
    r.mapcalc tmp_r7="tmp_r6 - tmp_r2"

    r.mapcalc tmp_r8="if(tmp_r7 <= -360 + ${direction_th} || (tmp_r7 >= -${direction_th} && tmp_r7 < ${direction_th} || tmp_r7 > 360 - ${direction_th}), 1, null())"


    ## Union of both filtering
    r.mapcalc tmp_r9="if(tmp_r5 == 1 && tmp_r8 == 1, tmp_r1, null())"
    r.mapcalc tmp_r10="if(tmp_r5 == 1 && tmp_r8 == 1, tmp_r2, null())"


    #<output>

    r.out.gdal -c input=tmp_r9 format=GTiff output=${screened_SCALAR_GTIFF_FILEPATH} nodata=-9999    
    r.out.gdal -c input=tmp_r10 format=GTiff output=${screened_DIRECT_GTIFF_FILEPATH} nodata=-9999

    #</output>


done

#</processing>


g.mremove -f rast=tmp*


echo -e "</SCREENING_FLOW>\n\n"
