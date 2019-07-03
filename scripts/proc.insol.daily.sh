#!/bin/bash

# Matthew Forrest 2019-02-04
#
# This script is based on my previous script for CRUNCEP.  It should produce a 'standard' file (no re-ordering) and a
# re-ordered file (for fast reading in LPJ-GUESS).
#
# Note that I have installed CDO version 1.9.2 and NCO 4.7.0 utilities locally to "~/local/bin/ 

# first and last years to process
first_year=1901
last_year=2018

# variable names
input_var="dswrf"
output_var="insol"

# method - first sum across the day to get the total incoming energy (J m-2 day-1) and then divide by seconds in the day to get average W m-2
method="sum" # should be "mean" or "sum"
daytoseconds=$((24*60*60)) 

# metadata
units="W m-2"
standard_name="surface_downwelling_shortwave_flux"

# directories
input_dir="/data/mforrest/Climate/CRUJRA/v2.0/raw"
output_dir="/data/mforrest/Climate/CRUJRA/v2.0/processed"


# --------------------------------------------------------------------------------


for (( year=${first_year}; year<=${last_year}; year++ ))
do
    echo $year

    # gunzip the bugger
    gunzip ${input_dir}/${input_var}/crujra.v2.0.5d.${input_var}.${year}.365d.noc.nc.gz

    # "The Chain" (Got Big Love for The Chain)
    # - take daily sum
    # - divide by seconds in the day 
    cdo -r divc,$daytoseconds -day${method} ${input_dir}/${input_var}/crujra.v2.0.5d.${input_var}.${year}.365d.noc.nc ${output_dir}/${output_var}.${year}.nc

    # update attributes
    ncrename -v ${input_var},${output_var} ${output_dir}/${output_var}.${year}.nc
    ncatted -O -a units,${output_var},m,c,"$units" ${output_dir}/${output_var}.${year}.nc
    ncatted -O -a standard_name,${output_var},c,c,${standard_name} ${output_dir}/${output_var}.${year}.nc

    # also make the monthly files
    cdo -r mon${method} ${output_dir}/${output_var}.${year}.nc ${output_dir}/${output_var}.${year}.monthly.nc


    # rechunk
    #nccopy -w -c lon/3,lat/7,time/365 ${output_dir}/${output_var}.${year}.nc ${output_dir}/${output_var}.${year}.rechunked.nc

    # re-gzip 
    gzip ${input_dir}/${input_var}/crujra.v2.0.5d.${input_var}.${year}.365d.noc.nc

done


# combine the non-chunked ones
ncrcat -O ${output_dir}/${output_var}.????.nc   ${output_dir}/crujra.v2.0.${output_var}.std-ordering.nc

# re-order the above for fast LPJ-GUESS reading
ncpdq -F -O -a lat,lon,time  ${output_dir}/crujra.v2.0.${output_var}.std-ordering.nc ${output_dir}/crujra.v2.0.${output_var}.nc 

# combine the chunked ones
#ncrcat -O ${output_dir}/${output_var}.????.rechunked.nc   ${output_dir}/crujra.v2.0.${output_var}.365x3x7.nc

# combine the monthly ones
ncrcat -O ${output_dir}/${output_var}.????.monthly.nc   ${output_dir}/crujra.v2.0.${output_var}.monthly.nc

# clean up
rm ${output_dir}/${output_var}.????.nc
rm ${output_dir}/${output_var}.????.monthly.nc
#rm ${output_dir}/${output_var}.????.rechunked.nc

 
