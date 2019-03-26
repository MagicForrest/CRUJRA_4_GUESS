# Details

Timing were done on the Goethe-HLR super computer using LPJ-GUESS 4.0.1.  Setups were the standard benchmarking runs (global and crop_global), with the standard 5 patches etc.  The runs used a single dual CPU node featurning 2 x Xeon Skylake Gold 6148 CPUs, each with 20 cores, for a total of 40 cores.

'standard' means the standard 0.5 degree gridlist which is ordered from highest to lowest latitudes.  'shuffled' means the standard cf global gridlist which has been randomised. 'dealt' means the the standard 0.5 degree gridlist was 'dealt' out like a pack of cards to each node (via a modifcation to the submist script).  This ensures the the low producutivity (high latitude cells) and high productivity (tropical) gridcells are distributed evenly across the processes given much improved load balancing.  

# Learnings

Firstly, 'dealing' out the gridcells can reduce the run time to about 63% of the 'non-dealt' setup.

Secondly, reading a properly constructed netCDF file (ie dimensions re-ordered) is not significantly slower than a reading a binary archive (with some load balancing on each) **even though the netCDF files are daily data**.     