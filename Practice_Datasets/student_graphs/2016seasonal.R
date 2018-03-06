
########Graphs and stuff###########
library(ggplot2)
library(cowplot)

#Load in data
meta2 <- read.csv("RespLong.csv", header = T)
meta2$TIMESTAMP <- as.POSIXct(meta2$TIMESTAMP)

#aggregate it for plotting
day <- aggregate(meta2, list(meta2$Day,meta2$Treatment, meta2$type, meta2$x ), mean, na.rm = T, row.names=F)
week <- aggregate(meta2, list(meta2$Week,meta2$Treatment, meta2$type, meta2$x ), mean, na.rm = T, row.names=F)
month <- aggregate(meta2, list(meta2$Month,meta2$Treatment, meta2$type, meta2$x), mean, na.rm = T, row.names=F)

#Pull in precip data
setwd("~/Documents/Ecosystem Modeling Lab/Gapfilling analysis/SoilT_VWC")
w <- read.csv("DailySNOTEL2016.csv", header = T)
w$Date <- as.POSIXct(w$Date, format = "%m/%d/%y")
w$TIMESTAMP <- w$Date


#Seasonal plot
p1 <- ggplot(subset(day,Group.4 == "Automated" & Group.3 == "Rh"), aes())+
  geom_line(show.legend = T, aes(x=TIMESTAMP, y=SoilFlux, color=Group.2, group=Group.2, fill = factor(Group.2)))+labs(fill = "Automated")+
  scale_colour_brewer(NULL, palette = "Set1", labels=c("Control","Treatment"),guide = guide_legend(override.aes = list(linestyle = c(0,0))))+
  scale_y_continuous(limits=c(0,8.5))+
  scale_x_datetime(date_breaks = "1 month", date_labels = "%b", limits=as.POSIXct(c("2016-06-20 11:45:00", "2016-12-05 11:45:00")))+ 
  xlab(NULL) + ylab(expression(~Soil~Efflux~(µmol~CO[2]~m^{-2}~s^{-1})))+
  theme_cowplot()
p1 <- p1 + theme(strip.background = element_rect(fill = "white")) + ggtitle("2016 Soil Rh")
p1 <- p1 + geom_point(data = subset(week,Group.4 == "Survey" & Group.3 == "Rh"), show.legend = T, inherit.aes = F,
                      aes(x=TIMESTAMP, y=SoilFlux, group = Group.2, colour = Group.2))
p1 <- p1 + scale_colour_brewer(guide = FALSE, palette = "Set1")
p1 <- p1 + geom_bar(data= subset(w, Group.2 == "Control"), aes(x=TIMESTAMP, y=Precip/8, alpha = 0.2), stat = "identity", position = "dodge") 
p1 <- p1 + scale_y_continuous(sec.axis = sec_axis(~.*8, name = "Precipitation (mm)"))
p1
