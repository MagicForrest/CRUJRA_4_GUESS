# CRUJRA_4_GUESS

### 2019-02-04

Set up the repo and lab book.

Started working on ceremony based on previous CRUCEP processing.  Removed all variable specific stuff to the top of the script.

Files seem easier to work with, no need to adjust time axis or invert latitudes.

Initially test re-ordering/no reordering to confirm metadata works etc.  Do chunking later.

At day's end submitted prec, temp, insol from 1901-1940 for testing.


### 2019-02-05

Set up LPJ-GUESS v4.0.1 to run on ceremony.  See ~/ModelConfigurations/v4.0.1 for the input setup and ~/LPJ-GUESS/guess_4.0.1 for the code.  Note that the netcdf_c++ lib was not necessary to be set in cmake.

Performed test of CRUJRA files (temp, insol and prec) for 1901-1940, test worked fine, so metadata A-okay.  These files were made overnight and took about 1hr wall time each (more-or-less).

Timings for a 13 gridcell sample: 

Standard Ordering:

real	 4m42.776s
user	 2m28.549s
sys	 2m14.197s

Re-ordered:

real	4m50.610s
user	2m35.442s
sys	2m15.152s

Very surprised that there is no difference here!  (I confirmed that the variables are actually re-ordered).  Will need to do some bigger tests to investigate further.  Probably on the new GOETHE-HLR cluter when I get access.

For today I will re-run the insol, prec and temp files for years up to 2015 to do longer tests.  (These processings tooks about 2.5 hours) 

### 2019-02-07

Since I now have the full time series I can test on the new GOETHE cluster (which will require some setup).

### 2019-02-08

Cluster setup on-going.  In the mean time I ran out to 2017 (will need to make a couple of years of dummy CO2 data until I get a proper up-to-dat CO2 file).

I also made monthly data for general convenience and testing.  However, the code to get rain days repeatedly seg faults, although it seemed to work in two individual steps outside of the script.  Most mysterious.

Two next steps:

1. Make files for chunking test.
2. Make 'derived' variables such as wind and relative humidity for SPITFIRE, but also VPD, 1 hour fuel moisture and 'wetting days' days (that seems likely to be problematic based on the above problem with wetdays).

Not sure what to do next.



### Future

Testing three data formats:

* No re-ordering/chunking ('control' setup which will be very slow)
* Simple re-ordering
* Rechunking to 365x2x2, 365x2x3, 365x1x5 (timexlonxlat)

Reasoning behind chunk size is to got for as close to 8 kB chunks as possible (see unidata blog)

number of floats per 8 kB chunk size = 8192 B / 4 B = 2048

Chunk with maximum 365 day length gives 2048 / 365 = 5.6 floats per day

