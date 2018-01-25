# Import-Export-Practice.R
#
# Script for practicing data import and export from R.

## Load the readxl library for working with Excel files
library(readxl)

## Set up some variables to use for file names
RapidEye.file <- "RapidEye_Availability_IBP.csv"
PRISM.file <- "PRISM_ppt_Moses_Lake_4km_2006_2015.csv"
excel.file <- "Lander-HAF_preferred_species_cover-031215.xlsx"
web.file <- "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv"

data.path <- "C:\\Users\\Jason Karl\\Documents\\GitHub\\REM504-DataScience\\Practice_Datasets"

## Set a working directory (this will work for today, but I don't normally do this.)
setwd(data.path)

# Import data from a CSV file - will turn string fields into factors!
# Check help file (?read.csv) for defaults
rapideye.data <- read.csv(RapidEye.file, header = TRUE)
summary(rapideye.data)

# Overwrite the rapideye.data object, treat strings as character fields
rapideye.data <- read.csv(RapidEye.file, header = TRUE, stringsAsFactors = FALSE)
summary(rapideye.data)


# Import CSV data where you need to skip some header lines
prism.data <- read.csv(PRISM.file, header = TRUE, skip = 10)

# Import a Worksheet from an Excel Workbook - will take first worksheet as default
excel.data <- read_excel(excel.file)

# Import a specific worksheet from EXcel
excel.data <- read_excel(excel.file, sheet="Plot Totals")

# Import data from a website
## Note that this only works this simply if you're accessing a file that is
## stored on a web server or FTP site. Accessing data via an API or through
## a site where you have to do a search/query/order is more complicated.
web.data <- read.csv(url(web.file), header = TRUE, stringsAsFactors = FALSE)


# Export R data to a CSV file
write.csv(web.data, file="some_data_to_save.csv")
