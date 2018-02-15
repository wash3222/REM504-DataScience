library(dplyr)
library(tidyr)

options(digits = 4)
data <- read.csv("C:/Users/User/Documents/GitHub/REM504-DataScience/Practice_Datasets/student_data/mast_fuels.csv", skip = 5, header = TRUE)

head(data)

#delete extra columns/copies of data
data <- data[,1:12]
head(data)

#change year since treatment to factor, change levels from (1,5,6) to (1, 5-6)
data$YST <- factor(data$YST)
levels(data$YST)
levels(data$YST) <- c("1","5-6","5-6")
levels(data$YST)
tail(data)

levels(data$FCAT)
levels(data$FCAT) <- c('f_100_1000h', 'f_10h', 'f_1h')
levels(data$FCAT)

#spread() can be difficult
a <- spread(data, FCAT, fuel)#1h, 10h, 100_1000h categories should line up by ASUB
head(a)

a <- data %>% 
  select(-fuelsqrt, -fuelln1) %>%
  group_by(ASUB) %>%
  spread(FCAT, fuel)
head(a)

a$f_total <- a$f_100_1000h + a$f_10h + a$f_1h
head(a)

#gather fuel loading classes 
a <- gather(a, fuel_class, fuel_load, c(f_100_1000h, f_10h, f_1h, f_total))
head(a)

