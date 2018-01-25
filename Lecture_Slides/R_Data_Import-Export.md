# Data Import/Export in R
R isn't going to be much use to you if you can't get data into and out of it. Luckily, R has some pretty easy and powerful import/export functions.

### Packages for data import/export
R can handle a number of data formats right out of the box, but if you want to do things like read Excel workbooks, Access databases, or SAS tables, you'll need to install and load some packages. We'll be using the following packages, so you'll want to go ahead and install them:
- readxl
- readr
- RODBC (for Windows users only. Mac and Linux, check out mdbtools)

## Importing CSV files
The good old comma-separate-value (CSV) file is one of the most basic and foolproof ways to get data into R. CSV files are simply plain text files where the values in the table are separated by commas. You can create CSV files from Excel, Google Sheets, and many other programs, and you can also create them by hand very easily with a text editor.
```
Example
```
You read a CSV into R using the __read.csv()__ function. This function requires only a single argument - the path/name of the CSV file. However, in practice, there are two additional arguments that you may want to specify.
header
stringsAsFactors
na.strings

## Importing other delimited text files

## Importing Excel Files using readxl
As much as we may want to get away from proprietary Microsoft formats, the reality is that it's not likely to happen anytime soon. So we're stuck with data in a bunch of Excel files. You could save each Excel file as a CSV and then import it, but that adds an extra step and creates an unnecessary copy of your data. Luckily you can use the readxl package to import your Excel data directly into R. Bonus: readxl runs on Windows, Mac, and Linux, and handles both the old and new Excel formats!
```
```

## Importing Microsoft Access tables
If you're on a Windows machine, you can read MS Access tables directly into R using the RODBC library. Note that you can only read Access tables, you can't write to them from R via RODBC. Believe it or not, you can actually read Access tables into R from a Mac or Linux machine too using the mdbtools program. mdbtools is an external program that you must first install (and it's kind of a pain to install on a mac, but perseverance pays off) and then call from within R. I've used mdbtools successfully on a Mac and also on a linux server.

The code block below illustrates 1) how to detect which OS R is running on and then load the appropriate package or make a system call, and 2) how to read in Access tables using both RODBC (windows) and mdbtools (mac/linux).

```

```  

## Importing data from a web location
Sometimes it's best or easiest just to read a data file directly over the internet. There could be several reasons for this: 1) you have a data file set up in a shared location that is accessible via the internet (e.g., GitHub, )

## Exporting data to CSV Files

## Saving .RData Files


## Additional resources
[DataCamp Community Blog Post on Importing Data](https://www.datacamp.com/community/tutorials/r-data-import-tutorial)
