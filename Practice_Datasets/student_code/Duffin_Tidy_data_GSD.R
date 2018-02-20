# Load libraries
library(dplyr)
library(tidyverse)

# Load data
path <- "C:/Users/duff8162/Documents/GitHub/REM504-DataScience/Practice_Datasets/student_data"
datacsv <- "Duffin_PEBBLE_2017_-006575.csv"
XSpebble.data <- read.csv(paste(path,datacsv,sep="/"),header = TRUE, stringsAsFactors = FALSE)

glimpse(XSpebble.data)

#keep only wanted columns
XSpebble.data <- XSpebble.data[,10:19]

#delete blank cells
XSpebble.data[XSpebble.data==""] <- NA
XSpebble.data <- XSpebble.data %>% drop_na()

#tidify. gather all cross sections into one row
XSpebble.tidy <- gather(XSpebble.data, key="CrossSection",value="GrainSize")

#Get rid of text and ranges
XSpebble.tidier <- separate(XSpebble.tidy, CrossSection, into=c("XS","XSNumber")) 
XSpebble.tidier <- separate(XSpebble.tidier, GrainSize, into=c("Lowerrange","GSmm_Finer_than"), sep=" - ")

#Delete mm at end of grainsize value
XSpebble.tidier$GSmm_Finer_than = as.numeric(gsub("\\mm", "",XSpebble.tidier$GSmm_Finer_than))

#Keep only wanted columns
XSpebble.tidiest <- subset(XSpebble.tidier, select = -c(XS, Lowerrange))

