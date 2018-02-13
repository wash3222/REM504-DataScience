# Data Import/Export in R
R isn't going to be much use to you if you can't get data into and out of it. Luckily, R has some pretty easy and powerful import/export functions.

### Packages for data import/export
R can handle a number of data formats right out of the box (try to keep methods simple and easy for others to access), but if you want to do things like read Excel workbooks, Access databases, or SAS tables, you'll need to install and load some packages. We'll be using the following packages, so you'll want to go ahead and install them:
- readxl - simple, cross platform package for reading Excel files - very hard to write back to excel however
- readr - offers some additional functionality, types for data import - part of tidyverse
- RODBC (for Windows users only. Mac and Linux, check out mdbtools) - Read Microsoft Access database tables.

## Factors
__Factors__ in R are variables (i.e., vectors) that can have only a limited number of values (called __levels__ in R). For example, if you have a field in a data table called month, you could make it into a __factor__ and limit the values to the names of the 12 months. This can help make sure you only have valid month names in your data. Factors can also be useful when you're doing analyses on categorical data but the categories are coded with numbers. In this case, factors are a way to force R to treat your attribute as categories instead of as numeric data. There are a bunch of other uses for factors, especially relative to linear modeling and ANOVAs.

Be careful, though, because factors can also be very limiting. For instance, if you have a factor defined, and you want to add some data that isn't defined in the factor, R will throw and error. This whole concept can become bothersome because of the default way in which R imports data. For import commands like __read.csv__ and __read.table__, R will automatically treat any string field as a factor. This can be a real drag, and I typically use an option in my import statements to prevent it.

## Importing CSV files
The good old comma-separate-value (CSV) file is one of the most basic and foolproof ways to get data into R. CSV files are simply plain text files where the values in the table are separated by commas. You can create CSV files from Excel, Google Sheets, and many other programs, and you can also create them by hand very easily with a text editor.

You read a CSV into R using the __read.csv()__ function. This function requires only a single argument - the path/name of the CSV file. However, in practice, there are two additional arguments that you may want to specify.
- __header__ = Does your file have a header row that defined the column names (default is true, but I usually like to specify it explicitly).
- __stringsAsFactors__ = Default is TRUE, I like to set this to FALSE.

```
RapidEye.file <- "RapidEye_Availability_IBP.csv"
rapideye.data <- read.csv(RapidEye.file, header = TRUE, stringsAsFactors = FALSE)
```

## Importing other delimited text files
You can use __read.table()__ to import CSV files as well or to import data that use other delimiters like tabs or spaces. With read.table, you need to specify a few more options:
- sep = What is the separator between the fields
- fill = Should R fill in blank cells? Default is FALSE.
```
rapideye.data <- read.table(RapidEye.file, sep=",", header = TRUE, stringsAsFactors = FALSE, fill = TRUE)
```

## Importing Excel Files using readxl
As much as we may want to get away from proprietary Microsoft formats, the reality is that it's not likely to happen anytime soon. So we're stuck with data in a bunch of Excel files. You could save each Excel file as a CSV and then import it, but that adds an extra step and creates an unnecessary copy of your data. Luckily you can use the __read_excel()__ function in the __readxl__ package to import your Excel data directly into R. Bonus: readxl runs on Windows, Mac, and Linux, and handles both the old and new Excel formats!
```
excel.file <- "Lander-HAF_preferred_species_cover-031215.xlsx"
# import first sheet by Default
excel.data <- read_excel(excel.file)
# Import a specific worksheet from EXcel
excel.data <- read_excel(excel.file, sheet="Plot Totals")
```

## Importing Microsoft Access tables
If you're on a Windows machine, you can read MS Access tables directly into R using the RODBC library. Note that you can only read Access tables, you can't write to them from R via RODBC. Believe it or not, you can actually read Access tables into R from a Mac or Linux machine too using the mdbtools program. mdbtools is an external program that you must first install (and it's kind of a pain to install on a mac, but perseverance pays off) and then call from within R. I've used mdbtools successfully on a Mac and also on a linux server.

The code block below illustrates 1) how to detect which OS R is running on and then load the appropriate package or make a system call, and 2) how to read in Access tables using both RODBC (windows) and mdbtools (mac/linux).

```
# Load RODBC package if running on Windows machine
if (Sys.info()[1]=="Windows") {
  library(RODBC)
}

# Access file location
access.file <- "some_database.mdb"

# If running on Windows
if (Sys.info()[1]=="Windows") {
  dima <- odbcConnectAccess(access.file)
  tblApp <- sqlFetch(dima,"tblApplicationConstants")
  tblPlots <- sqlFetch(dima,"tblPlots")
  tblSites <- sqlFetch(dima,"tblSites",stringsAsFactors=F)
  odbcClose(dima)
} else {
  ## Logic for importing tables in Linux using mdbtools
  tables <- c("tblApplicationConstants","tblPlots","tblSites","tblPeople")
  for (table in tables) {
    read.string <- paste("mdb-export -d '|' '",access.file,"' ",table,sep="")
    #message(read.string)
    assign(paste(table),read.table(pipe(read.string),sep="|",header=TRUE,stringsAsFactors=FALSE))
  }
}
```  

## Importing data from a web location
Sometimes it's best or easiest just to read a data file directly over the internet. There could be several reasons for this: 1) you have a data file set up in a shared location that is accessible via the internet (e.g., GitHub, )
```
# Import data from a website
## Note that this only works this simply if you're accessing a file that is
## stored on a web server or FTP site. Accessing data via an API or through
## a site where you have to do a search/query/order is more complicated.

web.file <- "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv"
web.data <- read.csv(url(web.file), header = TRUE, stringsAsFactors = FALSE)
```


## Exporting data to CSV Files
Writing R data out to a CSV file is pretty simple with the __write.csv()__ function. There are multiple options for the function if you need to do something funky, but it's pretty robust with the default settings.
```
# Export R data to a CSV file
write.csv(web.data, file="some_data_to_save.csv")
```

## Additional resources
[DataCamp Community Blog Post on Importing Data](https://www.datacamp.com/community/tutorials/r-data-import-tutorial)
