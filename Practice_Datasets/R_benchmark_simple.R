# For the purposes of benchmarking, let's create a vector of a billion random numbers.
# That will give R something to chew on and will allow us to see the speed differences
# between plain-old R and the alternative implementation Renjin

start <- Sys.time()
x <- rnorm(10^9)
end <- Sys.time()
elapsed<-end-start
print(elapsed)


## OK, let's pare this back to a reasonable 10 million and run this with Snowfall
x <- runif(10^7,1,10)

## Now the same thing in parallel
## First start the snowfall parallelization
sfInit(parallel=TRUE, cpus=2)
if( sfParallel() ) {
  cat( "Running in parallel mode on", sfCpus(), "nodes.\n" )
} else {
  cat( "Running in sequential mode.\n" )
}

## Because we'll be spawning multiple threads, we need to tell snowfall which objects
##   and packages each thread will need. We do that via Exports
sfExport("x")
#sfLibrary(raster)  ## Load libraries, but we don't need them here

## Now we run our code in parallel!
start <- Sys.time()
y <- sfLapply(x,log10)
end <- Sys.time()
print(end-start)

## Turn the parallelization off
sfStop()
