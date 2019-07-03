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
# 2019-03-25 Calculate relative humidity
# 2019-07-02 Updated for CRUJRA v2.0


#  For calculating relative humidity (rhum) from Temperature (T), air pressure (P) and specific humidity (Q)

#  rhum = 100 * AVP / SVP    ----------------------------------------------------------------------------------- (1)
#  where SVP = saturation vapour pressure and AVP = actual vapour pressure (both in kPa)
#
#  Buck equation for SVP from T
#  (note that this is the T > 0 approximation, using the T < 0 approximation where T < 0 gives more areas of relative humidity > 100% so is not optimal, although this is probably more of a numerical artefcat)
#
#  SVP =  0.61121 * exp(T*(18.678-(T/234.5))/(257.14+T)) ------------------------------------------------ (2)
#  where T is in deg C, and gives SVP in kPa
#
#  Actual vapour pressure via mixing ratio,
#  
#  MR = Q / (1.0 - Q) ----------------------------------------------------------------------------------- (3)
#  where Q is specific humidity in kg/kg
#
#  And actual vapour pressure,
#
#  AVP = (P * MR) / (0.6221 + MR) ----------------------------------------------------------------------- (4)
#  where P = air pressure 
#
#  Note that the units of P determine the units of AVP, so in the code below we divide the pressure data by 1000 to go to kPa like the SVP


# first and last years to process
first_year=1901
last_year=2018

# variable names
input_var_temp="tmp"
input_var_pres="pres"
input_var_sh="spfh"
output_var="rhum"

# method - should be "mean" or "sum"
method="mean"

# metadata
units="%"
standard_name="relative_humidity"

# directories
input_dir="/data/mforrest/Climate/CRUJRA/v2.0/raw"
output_dir="/data/mforrest/Climate/CRUJRA/v2.0/processed"


# --------------------------------------------------------------------------------


for (( year=${first_year}; year<=${last_year}; year++ ))
do
    echo $year

    # gunzip the bugger
    gunzip ${input_dir}/${input_var_temp}/crujra.v2.0.5d.${input_var_temp}.${year}.365d.noc.nc.gz
    gunzip ${input_dir}/${input_var_pres}/crujra.v2.0.5d.${input_var_pres}.${year}.365d.noc.nc.gz
    gunzip ${input_dir}/${input_var_sh}/crujra.v2.0.5d.${input_var_sh}.${year}.365d.noc.nc.gz


    # merge the input dataset for the calculation 
    cdo  merge ${input_dir}/${input_var_temp}/crujra.v2.0.5d.${input_var_temp}.${year}.365d.noc.nc ${input_dir}/${input_var_pres}/crujra.v2.0.5d.${input_var_pres}.${year}.365d.noc.nc  ${input_dir}/${input_var_sh}/crujra.v2.0.5d.${input_var_sh}.${year}.365d.noc.nc ${output_dir}/temporary_rhum.${year}.nc

    # "The Chain" (Got Big Love for The Chain)
    # - take daily mean
    # - calculate relative humidity following equations above (note the specific humidity = spfh (not Q) and pressure = press (not P) since that is what they are called in the input data)    
    #   (also note that the preceeding underscores signifiy a temporary variable which is not to be stored in the final netCDF) 
    cdo  -r day${method} \
     -expr,'_T=tmp-273.15; _SVP=0.61121 * exp(_T*(18.678-(_T/234.5))/(257.14+_T)); _MR=spfh / (1.0 - spfh); _AVP=((pres/1000) * _MR) / (0.6221 + _MR); rhum=100*_AVP/_SVP;rhum=(rhum>99.99)?99.99:rhum'  ${output_dir}/temporary_rhum.${year}.nc  ${output_dir}/${output_var}.${year}.nc
    rm ${output_dir}/temporary_rhum.${year}.nc

    # update attributes
    # ncrename -v ${input_var},${output_var} ${output_dir}/${output_var}.${year}.nc
    ncatted -O -a units,${output_var},m,c,${units} ${output_dir}/${output_var}.${year}.nc
    ncatted -O -a standard_name,${output_var},c,c,${standard_name} ${output_dir}/${output_var}.${year}.nc

    # also make the monthly files
    cdo -r mon${method} ${output_dir}/${output_var}.${year}.nc ${output_dir}/${output_var}.${year}.monthly.nc

    # rechunk
    #nccopy -w -c lon/1,lat/1,time/365 ${output_dir}/${output_var}.${year}.nc ${output_dir}/${output_var}.${year}.rechunked.nc

    # re-gzip 
    gzip ${input_dir}/${input_var_temp}/crujra.v2.0.5d.${input_var_temp}.${year}.365d.noc.nc
    gzip ${input_dir}/${input_var_pres}/crujra.v2.0.5d.${input_var_pres}.${year}.365d.noc.nc
    gzip ${input_dir}/${input_var_sh}/crujra.v2.0.5d.${input_var_sh}.${year}.365d.noc.nc

done


# combine the non-chunked ones
ncrcat -O ${output_dir}/${output_var}.????.nc   ${output_dir}/crujra.v2.0.${output_var}.std-ordering.nc

# re-order the above for fast LPJ-GUESS reading
ncpdq -F -O -a lat,lon,time  ${output_dir}/crujra.v2.0.${output_var}.std-ordering.nc ${output_dir}/crujra.v2.0.${output_var}.nc 

# combine the chunked ones
#ncrcat ${output_dir}/${output_var}.????.rechunked.nc   ${output_dir}/crujra.v2.0.${output_var}.365x3x7.nc

# combine the monthly ones
ncrcat -O ${output_dir}/${output_var}.????.monthly.nc   ${output_dir}/crujra.v2.0.${output_var}.monthly.nc

# clean up
rm ${output_dir}/${output_var}.????.nc
rm ${output_dir}/${output_var}.????.monthly.nc
#rm ${output_dir}/${output_var}.????.rechunked.nc

 
