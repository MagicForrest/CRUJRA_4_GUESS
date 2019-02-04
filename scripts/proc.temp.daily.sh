#!/bin/bash

# Matthew Forrest 2019-02-04
#
# This script is based on my previous script for CRUNCEP.  It should produce a 'standard' file (no re-ordering),
# re-ordered file (for fast reading in LPJ-GUESS) and a chunked file for testing
#
# Note that I have installed CDO version 1.9.2 and NCO 4.7.0 utilities locally to "~/local/bin/ 

# first and last years to process
first_year=1901
last_year=1902 # 2017

# variable names
input_var="tmp"
output_var="temp"

# method
method="daymean"

# metadata
units="K"
standard_name="air_temperature"

# directories
input_dir="/bigdata_local/mforrest/Climate/CRUJRA/v1.1/raw"
output_dir="/bigdata_local/mforrest/Climate/CRUJRA/v1.1/processed"


# --------------------------------------------------------------------------------


for (( year=${first_year}; year<=${last_year}; year++ ))
do
    echo $year

    # gunzip the bugger
    gunzip ${input_dir}/crujra.V1.1.5d.${input_var}.${year}.365d.noc.nc.gz

    # "The Chain" (Got Big Love for The Chain)
    # - take daily mean
    # - invert latitides
    cdo -r -f nc4 ${method} ${input_dir}/crujra.V1.1.5d.${input_var}.${year}.365d.noc.nc ${output_dir}/${output_var}.${year}.nc

    # update attributes
    ncrename -v ${input_var},${output_var} ${output_dir}/${output_var}.${year}.nc
    ncatted -O -a units,${output_var},m,c,${units} ${output_dir}/${output_var}.${year}.nc
    ncatted -O -a standard_name,${output_var},c,c,${standard_name} ${output_dir}/${output_var}.${year}.nc

    # rechunk
    #nccopy -w -c lon/3,lat/7,time/365 ${output_dir}/${output_var}.${year}.nc ${output_dir}/${output_var}.${year}.rechunked.nc

    # re-gzip 
    gzip ${input_dir}/crujra.V1.1.5d.${input_var}.${year}.365d.noc.nc

done


# combine the non-chunked ones
ncrcat -4  ${output_dir}/${output_var}.????.nc   ${output_dir}/crujra.v1.1.${output_var}.std-ordering.nc

# re-order the above for fast LPJ-GUESS reading
ncpdq -F -O -a lat,lon,time  ${output_dir}/crujra.v1.1.${output_var}.std-ordering.nc ${output_dir}/crujra.v1.1.${output_var}.nc 

# combine the chunked ones
#ncrcat -4  ${output_dir}/${output_var}.????.rechunked.nc   ${output_dir}/crujra.v1.1.${output_var}.365x3x7.nc


# clean up
rm ${output_dir}/${output_var}.????.nc
#rm ${output_dir}/${output_var}.????.rechunked.nc

 
