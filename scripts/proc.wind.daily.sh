#!/bin/bash

# Matthew Forrest 2019-02-04
#
# This script is based on my previous script for CRUNCEP.  It should produce a 'standard' file (no re-ordering) and a
# re-ordered file (for fast reading in LPJ-GUESS).
#
# Note that I have installed CDO version 1.9.2 and NCO 4.7.0 utilities locally to "~/local/bin/ 
#
# 2019-02-04 First attempt
# 2019-02-07 Added monthly files (no chunking and standard ordering)
# 2019-03-25 Calculate wind_speed (scalar)




# first and last years to process
first_year=1901
last_year=2017

# variable names
input_var1="vgrd"
input_var2="ugrd"
output_var="wind"

# method - should be "mean" or "sum"
method="mean"

# metadata
units="m/s"
standard_name="wind_speed"

# directories
input_dir="/bigdata_local/mforrest/Climate/CRUJRA/v1.1/raw"
output_dir="/bigdata_local/mforrest/Climate/CRUJRA/v1.1/processed"


# --------------------------------------------------------------------------------


for (( year=${first_year}; year<=${last_year}; year++ ))
do
    echo $year

    # gunzip the bugger
    gunzip ${input_dir}/crujra.V1.1.5d.${input_var1}.${year}.365d.noc.nc.gz
    gunzip ${input_dir}/crujra.V1.1.5d.${input_var2}.${year}.365d.noc.nc.gz

    # combine u and v windspeeds into a single file
    cdo  merge ${input_dir}/crujra.V1.1.5d.${input_var1}.${year}.365d.noc.nc ${input_dir}/crujra.V1.1.5d.${input_var2}.${year}.365d.noc.nc  ${output_dir}/temporary_wind.${year}.nc

    # "The Chain" (Got Big Love for The Chain)
    # - take daily mean
    # - calculate 6 hourly wind speed
    cdo  -r day${method} \
     -expr,'wind=(ugrd^2+vgrd^2)^0.5'  ${output_dir}/temporary_wind.${year}.nc  ${output_dir}/${output_var}.${year}.nc
    rm ${output_dir}/temporary_wind.${year}.nc

    # update attributes
    # ncrename -v ${input_var},${output_var} ${output_dir}/${output_var}.${year}.nc
    ncatted -O -a units,${output_var},m,c,${units} ${output_dir}/${output_var}.${year}.nc
    ncatted -O -a standard_name,${output_var},c,c,${standard_name} ${output_dir}/${output_var}.${year}.nc

    # also make the monthly files
    cdo -r mon${method} ${output_dir}/${output_var}.${year}.nc ${output_dir}/${output_var}.${year}.monthly.nc

    # rechunk
    #nccopy -w -c lon/1,lat/1,time/365 ${output_dir}/${output_var}.${year}.nc ${output_dir}/${output_var}.${year}.rechunked.nc

    # re-gzip 
    gzip ${input_dir}/crujra.V1.1.5d.${input_var1}.${year}.365d.noc.nc
    gzip ${input_dir}/crujra.V1.1.5d.${input_var2}.${year}.365d.noc.nc

done


# combine the non-chunked ones
ncrcat -O ${output_dir}/${output_var}.????.nc   ${output_dir}/crujra.v1.1.${output_var}.std-ordering.nc

# re-order the above for fast LPJ-GUESS reading
ncpdq -F -O -a lat,lon,time  ${output_dir}/crujra.v1.1.${output_var}.std-ordering.nc ${output_dir}/crujra.v1.1.${output_var}.nc 

# combine the chunked ones
#ncrcat -O ${output_dir}/${output_var}.????.rechunked.nc   ${output_dir}/crujra.v1.1.${output_var}.365x3x7.nc

# combine the monthly ones
ncrcat -O ${output_dir}/${output_var}.????.monthly.nc   ${output_dir}/crujra.v1.1.${output_var}.monthly.nc

# clean up
rm ${output_dir}/${output_var}.????.nc
rm ${output_dir}/${output_var}.????.monthly.nc
#rm ${output_dir}/${output_var}.????.rechunked.nc

 
