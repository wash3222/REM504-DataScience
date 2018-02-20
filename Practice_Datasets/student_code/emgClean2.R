#load required packages
library(dplyr)
library(plyr)

#Data processing function for soil respiration survey data
egmClean<-function(input, output1){
    data <- read.table(input, header = F, sep = ",", skip = 6, fill = T, stringsAsFactors = F, skipNul = T)
    data <- data[-c(1,9:14, 17:18, 23:45)]
    header <- cbind("date", "time", "collar", "rec", "co2ppm", "airp", "flowrate", "Tsoil", 
                    "Tair", "DC", "DT", "SRL", "SRQ")
    colnames(data) <- header
    data <- na.omit(data)
  data$date <- as.POSIXct(data$date, format = "%d/%m/%y")
  data$time <- paste(data$date, data$time)
  data <- data[-c(1)]
  data$time <- as.POSIXct(data$time, format = "%Y-%m-%d %H:%M:%S")
  data$DT <- as.numeric(data$DT)
  data$DC <- as.numeric(data$DC)
  data$SRL <- as.numeric(data$SRL)
  data <- data[data$DT == 60 & data$DC > 0 & data$SRL > 0,]
  data <- na.omit(data)
  data <- data %>% distinct(collar, SRL, .keep_all = TRUE)
  output.name <- paste0(processed, "/", output1)
  write.csv(data,file=output.name,row.names=FALSE)
}



#Set up file source
raw <- "/Users/danielleberardi/Documents/Ecosystem Modeling Lab/Gapfilling analysis/SoilRespiration/EGM5/BM/RAW"
processed <- "/Users/danielleberardi/Documents/Ecosystem Modeling Lab/Gapfilling analysis/SoilRespiration/EGM5/BM/processed"
key.file <-"/Users/danielleberardi/Documents/Ecosystem Modeling Lab/Gapfilling analysis/SoilRespiration/RsCollarKey.csv"

#Create file list
files <- list.files(raw, pattern = "*.TXT", full.names = T)
files.output <- list.files(raw, pattern = "*.TXT")
i <- length(files.output)
l <- length(files)

#Clean files with function
egmClean(files[11], files.output[11])


#Check output files
outputs <- list.files(processed, pattern = "*.TXT", full.names =T)
j <- length(outputs)
test <- read.csv(outputs[10], header = TRUE)

#merge outputs together
survey2017 <- 
  do.call(rbind,
          lapply(outputs, read.csv, header = TRUE))

#Use key.file to add plot information to the file. 
key <- read.csv(key.file, header=TRUE)
survey2017 <- left_join(key, survey2017, by = "collar")
#put the time column back as the first column
survey2017 <- survey2017 %>%
  select(time, everything())

##write annual file
output.annual <- "BM_annual_2017.csv"
annual.file <- paste0(processed, "/", output.annual)
write.csv(survey2017, annual.file, row.names = F)

