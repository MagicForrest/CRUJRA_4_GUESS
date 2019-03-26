# CRUJRA_4_GUESS
Process CRUJRA (2018, v1.1) climate data for reading by LPJ-GUESS.

## Overview
This is a simple package to bundle up the scripts (and documentation!) for a relatively simple task of processing climate data for reading by LPJ-GUESS.  For users of other vegetation models (particularly models running TRENDY simulations) this may also be useful, possibly with some minor  modifications.

## Aim
1. Take the CRUJRA data as downloaded (netCDF, sub-daily time resolution, one file per variable per year) and process it to daily values, one netCDF file per variable, with data and meta-data ready for LPJ-GUESSes 'cf' input module.  Note that for fast reading of the data in LPJ-GUESS, the dimensions should be re-ordered (see below).

2. Calculate 'derived' climate quantities such as windspeed and relative humidity (for the SIMFIRE-BLAZE and SPITFIRE fire models).  Note in some high latitude gridcells relative humidity can go over 100% (sometimes even 1000%) so it is capped is capped at 99.99%.  I believe this is just a numeric artifact, at such low temperatures both actual vapour pressure and saturation vapour pressure are very small numbers.  For potentially various reasons (eg. error in the empirical approximation of saturation vapour pressure or precision effects and/or very small inconsistencies in the data), the actual vapour pressure exceeds the saturation vapour pressure.  And whilst this positive difference is very small, it is relatively large compared to the very small vapour values, hence the apparently 'super-saturated' air. 

3. Produce monthly files for convenience and testing.

## Requirements

### Hardware
At daily resolution, the final files take up about 40 Gb each (uncompressed).  I therefore processed the data on a massive memory memory machine here at Senckenberg BiK-F, so that entire files can be handled in memory.  To repeat this processing it will probably be necessary to have a machine with many gigabytes (maybe 50?) of RAM.  If the dimension re-ordering step (the ncpdq command) is not required, then it is possible the such large amounts of RAM will not be required. 

### Software
Both `cdo` and `nco` for processing the netcdf files, also `bash` for the scripting.

## Details and Strategy
The requirements for the 'cf' input module of LPJ-GUESS is fairly strict in terms of meta-data (see documentation in /docs) but fairly loose in terms of the underlying structure of the data.  So there are decision to make here.  It is important to note that the 'standard'/'CF convention' data structure is *very* slow when read by LPJ-GUESS because this structre is optimised for reading data which continuous in **space** whereas LPJ-GUESS requires data that is continuous in **time**.  There are three options to handle this:

1. **Re-ordering** the dimensions (lon, lat and time) so that time comes last.  This has the disadvantage that some programs will be confused by this non-standard ordering (eg. `ncview`).  It also doesn't appear to work well for the netCDF4 format (see below). 
2. **Chunking**  the data into chuncks which are much longer in time than in lon/lat.  This optimises the data for reading of time series, but it is slower for reading spatial slices (ie looking at the maps in a viewer program).  See these two useful posts from Unidata (developers of netCDF) on chunking: [Chunking Data: Why it Matters](https://www.unidata.ucar.edu/blogs/developer/entry/chunking_data_why_it_matters) and [Chunking Data: Choosing Shapes](https://www.unidata.ucar.edu/blogs/developer/en/entry/chunking_data_choosing_shapes).
3. **Reduced Lon/Lat Grid** This involves melting the lon and lat into a single dimension (with variables to look up the longitude and latitude).  This is the most effective in terms of disk space (and I think maybe also read time) but the format is the least convenient to use and view from a human perspective. 

For simplicity, here I choose option 1., re-order the dimensions, however the scripts also make a files with the standard ordering for checking and visualisation (at the cost of writing another 40 Gb file per variable).

## Note on netCDF formats and chunking for netCDF

Whilst re-ordering 'classic' netCDF files produces files for which time series for one gridcell can be read perfectly efficiently with LPJ-GUESS, using the netCDF4 data format seems to mess this up.  I think the reason is that netCDF4 files are *always* chunked due to their underlying data structure, and `cdo` chucks the data for optimal reading of spatial slices (see the links above for that is important).  Therefore when using netCDF4 formatted files for LPJ-GUESS, appropriate chunking becomes essential.  Note that this is currently inferred from model performance, not conclusively tested.  In summary, the safest thing to do is to stick with netCDF 'classic' with re-ordered dimensions as is done here.  Using netCDF4 with appropriately chunked data is in some way optimal (access advanced features of netCDF4 and fiels can be easily viewed), but not fully investigated yet.


Questions? Contact matthew.forrest@senckenberg.de
