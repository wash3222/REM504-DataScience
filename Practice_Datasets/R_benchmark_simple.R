# For the purposes of benchmarking, let's create a vector of a billion random numbers.
# That will give R something to chew on and will allow us to see the speed differences
# between plain-old R and the alternative implementation Renjin

start <- Sys.time()
x <- rnorm(10^9)
end <- Sys.time()
elapsed<-end-start
print(elapsed)
