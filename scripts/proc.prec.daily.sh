#!/bin/bash

# Matthew Forrest 2019-02-04
#
# This script is based on my previous script for CRUNCEP.  It should produce a 'standard' file (no re-ordering),
# re-ordered file (for fast reading in LPJ-GUESS) and a chunked file for testing
#
# Note that I have installed CDO version 1.9.2 and NCO 4.7.0 utilities locally to "~/local/bin/ 
#
# 2019-02-04 First attempt
# 2019-02-07 Added monthly files including wetdays (no chunking and standard ordering)
# 2019-01-08 Wetdays code seg faulting all the time, don't know why.  Disabling for now.

# first and last years to process
first_year=1901
last_year=2017 # 2017

# variable names
input_var="pre"
output_var="prec"

# method - should be "mean" or "sum"
method="sum"

# metadata
units="kg m-2"
standard_name="precipitation_amount"

# also for precip calculate monthly wet days above 0.1 mm with following metadata
wetdays_output_var="wetdays"
wetdays_units="1" # stupid unit, but that is 'canonical' by the CF convention
wetdays_standard_name="number_of_days_with_lwe_thickness_of_precipitation_amount_above_threshold"
wetdays_long_name="number of days in month with greater than 0.1 mm of precipitation"


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
    cdo -r -f nc4 day${method} ${input_dir}/crujra.V1.1.5d.${input_var}.${year}.365d.noc.nc ${output_dir}/${output_var}.${year}.nc

    # update attributes
    ncrename -v ${input_var},${output_var} ${output_dir}/${output_var}.${year}.nc
    ncatted -O -a units,${output_var},m,c,"$units" ${output_dir}/${output_var}.${year}.nc
    ncatted -O -a standard_name,${output_var},c,c,${standard_name} ${output_dir}/${output_var}.${year}.nc

    # also make the monthly files
    cdo -r -f nc4 mon${method} ${output_dir}/${output_var}.${year}.nc ${output_dir}/${output_var}.${year}.monthly.nc

    # make wetdays above 0.1 mm and do atrributes
    #ls -ltrh ${output_dir}/${output_var}.${year}.nc
    #echo ${output_dir}/${wetdays_output_var}.${year}.monthly.nc
    #cdo -f nc4 monsum -gec,0.1 ${output_dir}/${output_var}.${year}.nc ${output_dir}/${wetdays_output_var}.${year}.monthly.nc
    #ncrename -v ${output_var},${wetdays_output_var} ${output_dir}/${wetdays_output_var}.${year}.monthly.nc
    #ncatted -O -a units,${wetdays_output_var},m,c,"$wetdays_units" ${output_dir}/${wetdays_output_var}.${year}.monthly.nc
    #ncatted -O -a standard_name,${wetdays_output_var},c,c,${wetdays_standard_name} ${output_dir}/${wetdays_output_var}.${year}.monthly.nc
    #ncatted -O -a long_name,${wetdays_output_var},c,c,${wetdays_long_name} ${output_dir}/${wetdays_output_var}.${year}.monthly.nc

  
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

# combine the monthly ones (including wetdays)
ncrcat -4  ${output_dir}/${output_var}.????.monthly.nc   ${output_dir}/crujra.v1.1.${output_var}.monthly.nc
#ncrcat -4  ${output_dir}/${wetdays_output_var}.????.monthly.nc   ${output_dir}/crujra.v1.1.${wetdays_output_var}.monthly.nc


# clean up
rm ${output_dir}/${output_var}.????.nc
rm ${output_dir}/${output_var}.????.monthly.nc
#rm ${output_dir}/${wetdays_output_var}.????.monthly.nc
#rm ${output_dir}/${output_var}.????.rechunked.nc

 
