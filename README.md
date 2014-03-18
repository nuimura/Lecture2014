Flow chart of glacier flow analysis
=======

##Data
* alos20081024_ortho_prism.tif
* alos20101203_ortho_prism.tif


##Step 1: Calculate displacement using Cosi-Corr
###Input
* alos20081024_ortho_prism.tif
* alos20101203_ortho_prism.tif

###Cosi-Corr
* static mode
* window: 16
* step: 1
* range: 10

###Output
* disp20081024_20101203
* disp20081024_20101203.hdr
* disp20081024_20101203.tif


##Step 2: Decompose multi band file to single files and derivatives using R
###Input
* disp20081024_20101203.tif

###R
* decompositeVector.r
    * corr.th <- 0.6
    * outlier.th <- 100
    * magnitude.th <- 6

###Output
* disp20081024_20101203_x2.5.tif
* disp20081024_20101203_y2.5.tif
* disp20081024_20101203_corr2.5.tif
* disp20081024_20101203_scalar2.5.tif
* disp20081024_20101203_direct2.5.tif


##Step 3: Screening noise using GRASS GIS
###Input
* lirung_gl_area_extended_grid2.5.tif
* disp20081024_20101203_scalar2.5.tif
* disp20081024_20101203_direct2.5.tif

###GRASS GIS
* screening_flow.sh
    * Window: 51
    * direction_th=60

###Output
* disp20081024_20101203_scalar_screened2.5_window51.tif
* disp20081024_20101203_direct_screened2.5_window51.tif


##Step 4: Export data as points for using other software GMT etc.
###Input
* disp20081024_20101203_scalar_screened2.5_window51.tif
* disp20081024_20101203_direct_screened2.5_window51.tif

###R
* vector4gmt.r
    * cellsize <- 25

###Output
* vector_data_25.csv
