# Understanding R Objects
R is an object-based language, and just about everything you do in R creates or uses objects. A large portion of most analyses and projects in R is managing and converting object types. Here is some basic information on different R objects and data types.

## Some very helpful R functions for objects
Sometimes in R you will have objects and you don't know what type they are. Two really helpful functions to use are __class()__ which outputs the class of an object and __typeof()__ which tells you how R is storing the values.
```
> x <- 1
> class(x)
[1] "numeric"
> typeof(x)
[1] "double"
> y <- "a"
> class(y)
[1] "character"
> typeof(y)
[1] "character"
```

Another helpful set of functions for working with objects are the is.* functions. These are simple logical tests for different types of objects. For example,
```
> string <- "abcdefg"
> is.vector(string)
[1] TRUE
> is.character(string)
[1] TRUE
> is.list(string)
[1] FALSE
```
This is really useful when you need to check the specific type of object you're working with.

Finally, the __summary()__ function is useful for getting summaries and some additional info on objects. If you call summary on a numeric vector, it will return summary stats for the vector. On a character vector, it will tell you the length and class. On more complicated types like data frames and lists, it will return even more useful information.
```
> x.vector <- c(1,2,3,4,5,6)
> summary(x.vector)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
   1.00    2.25    3.50    3.50    4.75    6.00
   > d.frame <- data.frame("x"=c(1,2,3,4,5,6),y=c("a","b","b","a","a","a"))
> summary(d.frame)
          x        y
    Min.   :1.00   a:4
    1st Qu.:2.25   b:2
    Median :3.50
    Mean   :3.50
    3rd Qu.:4.75
    Max.   :6.00
```

## Vectors
The basic data type in R is a __Vector__. A vector can be a single value or character string, or it can be a set of values (i.e., more like what we learned as vectors in math/physics class). Vectors in R are homogeneous, meaning that you can't mix types of data in a vector. Vectors in R are of a couple of different flavors

### Numeric
Numeric vectors are, obviously, numbers, and they can be either integers or double-precision decimal values.

### Character
Any alphanumeric character can be a character vector. Character vectors are created using quotation marks around the character string. When you import data, if the column has any non-numeric characters in it, it is brought in as a character vector.

### Logical
Logical vectors are either TRUE or FALSE. These also equate to 1 or 0.

### Creating vectors
You create vectors by simple assignment in R
```
x <- 1
myOffice <- "205D"
```
You can also combine single-value vectors into longer vectors using the __c()__ function.
```
x <- c(1,2,3,4)
y <- c("a","b","c","d")
```
Note that vectors must contain values from the same data type. So, this wouldn't work in R
```
x <- c(1,2,"a","b")  # Will throw an error because you're mixing data types in a vector.
```

### Matrices
A matrix in R is simply a 2-dimensional vector. You can think of it as an Excel spreadsheet that has no column or row headings.

## Data Frames
You can generally thing of a data frame in R as a table. It looks like a matrix, but it can have different data types (numeric, character, logical) in it. Data frames also can have named columns and rows which make it easy to do queries and filters to subset your data. Often when you import tabular data, it will come in as a data frame. Data frames are one of the most common types of R objects you'll use for analysis.
```
> my.data <- read.csv("C:\\Users\\Jason\\Documents\\fake_data.csv", header=TRUE)
> class(my.data)
[1] "data.frame"
```

## Lists
Lists in R are cool, somewhat mystical, and just about everywhere. In R, a list is a collection of other objects. Lists can contain vectors, matrices, data frames, even other lists! The different parts of a list can be assigned names to make it easier to reference or retrieve information from them. At this point, we won't try to dive too deep into lists, except to point out that the result of many R analysis functions is a list.
```
> x <- rnorm(100,1) # Vector of 100 values from a random distribution with mean=1
> y <- rnorm(100,2) # Vector of 100 values from a random distribution with mean=1
> simple.t.test <- t.test(x,y) # run a simple t-test to see if x and y are different
> class(simple.t.test)
[1] "htest"
> typeof(simple.t.test)
[1] "list"
> names(simple.t.test)
[1] "statistic"   "parameter"   "p.value"     "conf.int"   
[5] "estimate"    "null.value"  "alternative" "method"     
[9] "data.name"  
> simple.t.test # output results of the test. What is output is determined as part of how the class "htest" was defined.

	Welch Two Sample t-test

data:  x and y
t = -5.2737, df = 197.2, p-value = 3.5e-07
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
 -1.040336 -0.474042
sample estimates:
mean of x mean of y
 0.994895  1.752084
```

## Coercing objects in R
Sometimes in R you need to make one object type into another (or at least try to!). You can usually do this in a couple of ways. One way is to use an _as.*()_ function to coerce the conversion.
```
x <- "1" # Create a vector but force it to be a character.
y <- as.numeric(x) # Force it to be a numeric vector.
```
Another way (and arguably more elegant), is to use object creation functions to do it.
```
mat <- matrix(c(1,2,3, 6,7,8),nrow=2,ncol=3) # Create a 2x3 matrix
m.dataframe <- data.frame(mat)
```

## More info
Some helpful resources for better understanding R objects can be found at:
- [R for Beginners](https://cran.r-project.org/doc/contrib/Paradis-rdebuts_en.pdf)
- [Base R Cheat Sheet](http://github.com/rstudio/cheatsheets/raw/master/base-r.pdf)
- [R for Excel Users](http://rex-analytics.com/r-for-excel-users/)
