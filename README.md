# CRUJRA_4_GUESS
Process CRUJRA (2018, v1.1) climate data for reading by LPJ-GUESS.

## Overview
This is a simple package to bundle up the scripts (and documentation!) for a relatively simple task of processing climate data for reading by LPJ-GUESS.  It is also should serve as a test case for building better practices in terms of reproducable science here in Senckenberg BiK-F (AG Hickler, AG Scheiter, Data and Modelling Centre and others).

## Aim
Take the CRUJRA data as downloaded (netCDF, sub-daily time resolution, one file per variable per year) and process it to daily values, one netCDF file per variable, with data and meta-data ready for LPJ-GUESSes 'cf' input module.

## Requirements

### Hardware
At daily resolution, these files will take up about 40 Gb each (uncompressed).  Therefore the plan is to do all the processing on ceremony, a massive memory memory here at BiK-F, so that entire files can be handled in memory.  To repeat this processing it will probably be necessary to have 

### Software
Most likely `cdo` and `nco` for processing the netcdf filkes .  The `cdo` package is installed onm ceremony, and I have a personal version of `nco` compiled on ceremony.  Also `bash`.

## Details and Strategy
The requirements for the 'cf' input module of LPJ-GUESS is fairly strict in terms of meta-data (see documentation in /docs) but fairly loose in terms of the underlying structure of the data.  So there are decision to make here.  It is important to note that the 'standard'/'CF convention' data structure is *very* slow when read by LPJ-GUESS because this structre is optimised for reading data which continuous in **space** whereas LPJ-GUESS requires data that is continuous in **time**.  There are three options to handle this:

1. **Re-ordering** the dimensions (lon, lat and time) so that time comes last.  This has the disadvantage that some programs will be confused by this non-standard ordering.
2. **Chunking**  the data into chuncks which are much longer in time than in lon/lat.  This optimises the data for reading of time series, but maybe it is slower for reading spatial slices (ie looking at the maps in a viewer program).  See these two useful posts from Unidata (developers of netCDF) on chunking: [Chunking Data: Why it Matters](https://www.unidata.ucar.edu/blogs/developer/entry/chunking_data_why_it_matters) and [Chunking Data: Choosing Shapes](https://www.unidata.ucar.edu/blogs/developer/en/entry/chunking_data_choosing_shapes)
3. **Reduced Lon/Lat Grid** This involves melting the lon and lat into a single dimensions.  This is the most effective in terms of disk space (and I think also read time) but the format is the least convenient to use and view from a human perspective. 






