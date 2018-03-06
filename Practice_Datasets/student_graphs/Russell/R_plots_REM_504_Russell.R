##########################################Script_1##############################################

# Run this script before any others

# This script produces and saves a table ("playa_wetness.csv") that contains, for each combination
# of playa ID and time step (month/year), the percentage of playa pixels with valid values that were wet 
# (pct.wet) and also the percent of playa pixels with missing data (Pct.NoData)

# Workspace setup
# Install packages if not already installed
required.packages <- c("ggplot2", "raster", "sp", "rgdal", "plyr", "ncdf4", "DescTools", "rgeos", "maptools")
new.packages <- required.packages[!(required.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
rm(required.packages, new.packages)

library(ggplot2)
library(raster)
library(sp)
library(rgdal)
library(plyr)
library(ncdf4)
library(DescTools)
library(rgeos)
library(maptools)
options(scipen = 999) # turn off scientific notation

# Read in playa polygons:
# (Note that there are only 5 playa polygons in this file bc this is a template)
setwd("D:/russ5140/Playa Project/Feb_18_Test/Input/playa_polygons")
all.playas <-readOGR(".", "Playa_sample")

# Read in surface water data
setwd("D:/russ5140/Playa Project/Feb_18_Test/Input/monthly_surface_water")
SW.files <- list.files(pattern="tif$") #get a list of all the monthly surface water file names

# Read and store the projection (coordinate system) and resolution of the surface water data
proj.use <- projection(raster(SW.files[1]))
res.use <- res(raster(SW.files[1]))

# Project the playa polygon to match the surface water files
all.playas <- spTransform(all.playas, CRS=proj.use)

# Create empty data frame to store playa inundation calculations
playa.inundation <- data.frame()

for (P in 1:nrow(all.playas)){  # Loop through playas and process each playa
  playa <- all.playas[P,] # Get a single playa for processing below
  playa.ID <- playa$PlayaID # Get the unique ID for this playa
  
  # for this playa, read in surface water data 
  for (F in SW.files){
    setwd("D:/russ5140/Playa Project/Feb_18_Test/Input/monthly_surface_water")
    SW <- raster(F) # read in the surface water raster, store as a raster called SW
    SW.name <- names(SW) # store the name of the raster, which is needed to determine the month and year
    
    # Get the year from SW.name
    year.pattern="X(.*?)_"  # find the string in between "X" and "_"
    year <- regmatches(SW.name,regexec(year.pattern,SW.name))[[1]][2] # extract the year as a string
    year <- as.integer(year) # convert the string to an integer value
    
    # Get the month from SW.name
    month.pattern="_(.*?).water"  # find the string in between "_" and ".water"
    month <- regmatches(SW.name,regexec(month.pattern,SW.name))[[1]][2] # extract the month as a string
    month <- as.integer(month) # convert the string to an integer value
    
    # Clip the surface water raster to the playa we are currently working on
    SW.playa <- mask(crop(SW, playa), playa)
    
    # Count number of grid cells for this playa in each cateogory (wet, dry, or NoData)
    ncell.dry <- length(SW.playa[SW.playa==1]) # count the number of dry cells, (value=1)
    ncell.wet <- length(SW.playa[SW.playa==2]) # count the number of wet cells, (value=2)
    ncell.NoData <- length(SW.playa[SW.playa==0]) # count the number of cells with missing data (value=0)
    
    # Calculate percent inundation as ncell.wet / (ncell.wet + ncell.dry) x 100
    pct.wet <- (ncell.wet / (ncell.wet + ncell.dry)) *100
    
    # Calculate percent missing data
    pct.NoData <- (ncell.NoData / (ncell.wet + ncell.dry + ncell.NoData)) *100
    
    # Compile the playa ID, month, year, pct.wet, and pct.NoData into a row for a table
    row <- data.frame(playa.ID, month, year, pct.wet, pct.NoData)
    
    # Add this row to the table of playa inundation calculations
    playa.inundation <- rbind(playa.inundation, row)
    
    # Clean up
    rm(SW, SW.name, year.pattern, month.pattern, ncell.dry, ncell.wet, ncell.NoData, row)
    
    ##
    pdf(paste("D:/russ5140/Playa Project/Feb_18_Test/Output/plots/inundation_timestep/", "playa_", playa.ID, "_", month, "_", year, ".pdf", sep = ""))
    
    # Plot the playa at this timestep
    breakpoints <- c(-100,0,1,2)
    colors <- c("gray","yellow","blue")
    plot(SW.playa, breaks=breakpoints, col=colors, legend=FALSE,
         main=paste("playa.ID = ", playa.ID, "       ", round(pct.wet,2), "% wet      ", round(pct.NoData,2), "% missing data", sep=""))
    plot(playa, add=TRUE)
    mtext(paste("month =", month, "         year=", year))
    legend(x="top", bty="y", c("No Data","Dry","Wet"), 
           ncol=3, cex=1,
           fill=c("gray","yellow","blue"))  
    dev.off()
    
    
    # Clean up
    rm(breakpoints, colors, SW.playa, pct.wet, pct.NoData, month, year, F)
    
  } # end loop across surface water rasters 
  
  # Clean up
  rm(playa.ID, playa, P)
  
} # end loop across playas

# Save results

setwd("D:/russ5140/Playa Project/Feb_18_Test/Output/tabular")
write.csv(playa.inundation, "playa_wetness.csv")

#####################Script_2####################################

# First run "1.Calc.playa.inundation.R"

# This script produces and saves rasters for each month (2=Bebruary through 10=October) of 
# percent wetness in all input playas for that month averaged across all the available years. For
# example, pct_wet_03 is a raster with values for all playa pixels representing the percentage of
# March observations (across all years) that were wet. This script also produces and saves rasters
# for each month of data availability (0=none, 1=complete data with no missing values) across
# all the input years. Pixels with very low data availability (below some threshold) may be deemed
# to have inadequate data availability to report a pixelwise percent wetness for that particular
# month (i.e. the data availability rasters could be used to mask the percent wetness rasters).

for (M in 2:10){ # loop through months February through October
  
  SW.files.this.month <- SW.files[grep(paste("_", as.character(sprintf("%02d", M)), ".", sep=""), SW.files)]
  
  # Create blank rasters to store mosaicked results across all playas for this month
  pct.wet.all.playas <- raster()
  extent(pct.wet.all.playas) <- extent(all.playas)
  projection(pct.wet.all.playas) <- proj.use
  res(pct.wet.all.playas) <- res.use
  data.avail.all.playas <- pct.wet.all.playas
  
  # Loop through playas and process each playa
  for (P in 1:nrow(all.playas)){  # Loop through playas and process each playa
    playa <- all.playas[P,] # Get a single playa for processing below
    playa.ID <- playa$PlayaID # Get the unique ID for this playa
    
    playa.month.stack <- stack()
    playa.month.avail.stack <- stack()
    
    for (F in SW.files.this.month){ # loop across years for this month and this playa
      setwd("D:/russ5140/Playa Project/Feb_18_Test/Input/monthly_surface_water")
      SW <- raster(F) # read in the surface water raster, store as a raster called SW
      SW.name <- names(SW) # store the name of the raster, which is needed to determine the month and year
      
      # Clip the surface water raster to the playa we are currently working on
      SW.playa <- mask(crop(SW, playa), playa)
      
      # Create a raster representing data availability (1=data, 0=no data)
      SW.playa.avail <- SW.playa
      SW.playa.avail[SW.playa.avail>0]<- 1
      
      # Transform SW.playa to 1=wet, 0=dry; NA=NA
      SW.playa[SW.playa==0]<- NA
      SW.playa[SW.playa==1]<- 0
      SW.playa[SW.playa==2]<- 1
      
      playa.month.stack <- stack(playa.month.stack, SW.playa)
      playa.month.avail.stack <- stack(playa.month.avail.stack, SW.playa.avail)
      
    } # end loop across years for this month and this playa
    
    # Average the playa wetness stack for this month
    playa.month.mean <- mean(playa.month.stack, na.rm=TRUE)
    pdf(paste("D:/russ5140/Playa Project/Feb_18_Test/Output/plots/monthly_pixelwise_mean_wetness/", "playa_", playa.ID, "_", M, ".pdf", sep = ""))
    plot(playa.month.mean, main=paste("playa.ID = ", playa.ID, "month =", M, "      percent wetness"))
    dev.off()
    
    # Create a raster of percent data availability, which could be used to screen out pixels with insufficient data
    playa.month.availability <- mean(playa.month.avail.stack, na.rm=TRUE)
    plot(playa.month.availability, main=paste(M, "      percent data available"))
    
    # Mosaic with other playas for this same month
    pct.wet.all.playas <- mosaic (pct.wet.all.playas, playa.month.mean, fun=mean)
    data.avail.all.playas <- mosaic (data.avail.all.playas, playa.month.availability, fun=mean)
    
  } # end loop across playas (note still within loop for this month)
  
  # Save results for this month
  setwd("D:/russ5140/Playa Project/Feb_18_Test/Output/rasters/monthly_pct_wetness")
  writeRaster(pct.wet.all.playas, paste("pct_wet_", sprintf("%02d", M), ".tif", sep=""), overwrite=TRUE)
  setwd("D:/russ5140/Playa Project/Feb_18_Test/Output/rasters/monthly_data_availability")
  writeRaster(data.avail.all.playas, paste("data_avail_", sprintf("%02d", M), ".tif", sep=""), overwrite=TRUE)
  
} # end loop across months from March to October

# cleanup
rm(F, M, P, playa.ID, playa.month.stack, playa.month.avail.stack)
rm(SW, SW.files.this.month, SW.name, SW.playa, SW.playa.avail)
rm(playa, playa.month.availability, playa.month.mean)