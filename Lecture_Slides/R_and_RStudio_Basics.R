## This script covers some basics of R that sometimes trip people up. It is not intended
## to be a comprehensize tutorial or intro to R. See one of the DataCamp modules if you
## need that kind of thing.

#############################################################################
## Comments
#############################################################################
# Single-line comments are created with the pound sign (#)
'
Multiple line comments
can be created by
using quotes before and after the comment.
This is legit, but RStudio might
not always render it correcly
in the script editor.
You are essentially creaating a
character object that is not saved.
'

# You should liberally comment your code with meaning and rationale for what
# you're doing. This is for you as much as it is for other people. Your own
# code may not make much sense to you when you come back to it after a year
# or more.

#############################################################################
## Filenames and pathways in R
#############################################################################
# Load a CSV file
df <- read.csv("C:\\Users\\Jason Karl\\Downloads\\IBP_RapidEye_Availability.csv",header=T,stringsAsFactors=F)

## A note on filenames when using R in Windows ##
# Windows uses the backslash (\) to separate directories in pathways and filenames.
# This creates a problem with cross-platform programs like R (or Python) that can also
# be run on Mac and Linux computers for two reasons:
# 1. Mac and Linux use a forward slash (/) to separate directories in a pathway
# 2. The backslash is part of the syntax for regular expression pattern matching, and
#    confuses R - i.e., it thinks you're trying to create a regular expression.
#
# There are two solutions for Windows:
# 1. Use a double-backslash in your pathways
#    e.g., f <- "C:\\Users\\Jason Karl\\Downloads\\IBP_RapidEye_Availability.csv"
# 2. Use a forward slash in your pathways
#    e.g., f <- "C:/Users/Jason Karl/Downloads/IBP_RapidEye_Availability.csv"

# List the names of the columns/attributes
names(df) 

# List the first 10 rows of the dataframe
head(df) 

#############################################################################
## Assignment versus Evaluation
#############################################################################
# R is an object-based language. Just about everything you do creates an object
# in R. The process of creating an object is called Assignment, and assignment
# is accomplished either through the assignment operator (<-) or a single equal 
# sign (=). So
mvVar <- 123
# is the same as
myVar = 123
#
# When you need to select data or set up loops, etc., you often need to perform
# an evaluation - e.g., data rows that equal some value. Evaluation in R uses
# a double equal sign (==). For example,
myVar == 123 # returns True
myVar == 1 # returns False
#
# I find that it's best in R to avoid using the single equal sign for assignment
# to help clarify my code and avoid confusion as to what is going on.


#############################################################################
## R Workspaces
#############################################################################
# R creates a workspace to hold all of your objets whenever you start R. This
# workspace is associated with a directory on your computer, but by default all
# of the objects are held in computer RAM unless you tell it to save the objects
# to your working directory. This can be useful for saving your session if you
# need to quit R and restart later.
getwd() # Get the current working directory
setwd("C:\\Users\\Jason Karl\\Downloads") # Set the working directory to a new location
save(list=ls(),file="all.RData") # Save all objects in the current workspace
load("all.RData") # Load objects from a saved R workspace

# My unsolicited opinion is that you should use saved workspaces sparingly. During
# the course of an analysis, you create a bunch of temporary or junk objects that
# take up memory and can get in the way or cause confusion later on. I don't like to
# save these. One reason why we write scripts is so that we don't need to save these
# kinds of temporary objects.
# My general rule of thumb is that if I can recreate something in less than 5 minutes,
# I don't need to save it as an object.


#############################################################################
## Managing Objects
#############################################################################
# As stated above, just about everything you do in R creates objects. Eventually
# you will have so many objects running around that it's hard to find what you
# want, and they take up memory on your computer. The following commands help
# manage your objects
ls() # list all the objects
ls(pattern="d") # list all objects starting with letter d
rm(myVar) # remove a variable
rm(list=ls()) # remove all the objects in your R workspace. USE WITH CAUTION


#############################################################################
## Installing Packages
#############################################################################
install.packages("dplyr") # Installs a package from the CRAN
# or can do it via the Tools menu in RStudio

#############################################################################
## Loading Packages
#############################################################################
# You should use library to load packages in R.
# Loading packages with require can cause problems if the package doesn't exist or fails
# to load properly
require(dplyr3) # No such package as this. Require will give a warning, but won't abort code
                # execution.
test <- filter(data, abs(view_angle)<7) #Script will fail here instead of at package load.
                                        #This is problematic because there is another R
                                        #command called "filter" that fits a time series to
                                        #data. You were meaning to run filter from dplyr, but
                                        #because that package failed to load, the other
                                        #filter command didn't get masked out, and R is trying
                                        #to run it here.

# Load packages with library instead
library(dplyr) #Script will fail/abort here if a package doesn't exist or fails to load.
               #This is where you want it to fail.
test <- filter(data, abs(view_angle)<7)

