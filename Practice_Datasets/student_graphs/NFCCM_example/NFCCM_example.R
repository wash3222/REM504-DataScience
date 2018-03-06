#mdir <- 'H:/'
mdir <- '/Volumes/Seagate/'
library(RColorBrewer)
library(lattice)
library(ggplot2)
library(maps)
library(rgdal)
library(maptools)
library(plyr)
library(ggmap)
library(colorRamps)
library(grid)
library(gtable)
library(gridExtra)
library(Cairo)
library(RgoogleMaps)
library(proto)
library(png)
library(raster)
symbol <- readPNG(paste0(mdir,'north-arrow-filled.png'))
source(paste0(mdir,'scalebar2.R'))



projurl <- 'https://www.fs.fed.us/rm/boise/AWAE/projects/national-forest-climate-change-maps.html'
cust <- read.table(paste0(mdir, 'MACA_futures/Snow/Snow_map_customization_table2.txt'))

source(paste0(mdir,'FIX_get_stamenmap_RCode.R'))
source(paste0(mdir,'getbreaks.R'))
source(paste0(mdir,'colorbar2sided.R'))
# Get MACA Data: #################################################################################
dir <- paste0(mdir,'MACA_futures/Aggregated_Data/Winter_climatologies/Ensemble_winter_climatologies/')

Ahist <- read.table(paste0(dir,'Predicted_historical_A1SWE.txt'))
Afut <- read.table(paste0(dir,'Predicted_rcp85_A1SWE.txt'))
Apc <- (Afut-Ahist)/Ahist*100
Aac <- (Afut-Ahist)
pvec <- as.vector(as.matrix(Apc))
pveca <- as.vector(as.matrix(Aac))
rm(Ahist,Afut,Apc,dir,Aac)

dir1 <- paste0(mdir,'MACA_MetData/')
lats <- read.table(paste0(dir1,'lats.txt'))
lons <- read.table(paste0(dir1,'lons.txt'))
d1 <- dim(lons)[1]
d2 <- dim(lats)[1]
latvec <- rev(rep(as.vector(as.matrix(lats)),each=d1))
lonvec <- rep(as.vector(as.matrix(lons)),d2)

A1df <- data.frame(pvec,latvec,lonvec)   
A1dfa <- data.frame(pveca,latvec,lonvec) 
#write.csv(A1df,'H:/MACA_MetData/RioGrande_A1SWE_pc2.csv')

A1df2 <- A1df[which(!is.na(A1df$pvec)),]
A1_nosnow <- A1df2[which(A1df2$pvec== -100),] 
A1df2 <- A1df2[which(!A1df2$pvec== -100),]
A1df2a <- A1dfa[which(!is.na(A1df$pvec)),]
#A1df2a <- A1df2a[which(!is.na(A1dfa$pvec)),]

rm(latvec,lonvec,pvec,lats,lons,d1,d2)
dummy <- data.frame(cbind(c(1,1),c(-120,-110),c(40,50)))
names(dummy) <- c('No','lon','lat')
#cols <- c('darkorange',rev(topo.colors(10))[4:10],'blueviolet','thistle',rep('white',9))
cols <- c(rev(matlab.like(112))[1:63],rev(matlab.like2(112))[77:100])#rep('white',4),
#cols <- c(rev(matlab.like(112))[1:50],rep('white',3),rev(matlab.like2(112))[62:82])
cols1 <- rev(matlab.like(112))[1:63]
plot(rep(1,length(cols)),1:length(cols),bg=cols,col=cols,cex=3,pch=21)
brks <- seq(-100,12,10)



# Get States Layer: ####################################
#dirs <- 'H:/MACA_MetData/States_layer' #appears that no last slash is needed, causes error!
dirs <- paste0(mdir,'MACA_MetData/States_layer')

states <- readOGR(dsn=path.expand(dirs),'States_proj')
bs <- which(states@data$STATESP020 %in% c(1263,1295,1311,1323,1500,1524,1716,1718,1720,1735)) # remove strange looking waterbodies from states shapefile:
states@data <- states@data[-(bs+1),]
states@polygons <- states@polygons[-(bs)]
states@data$id <- rownames(states@data) # Explicitly identifies attribute rows by the .dbf offset
states.df <- as.data.frame(states)
states.fort <- fortify(states, region="id")
states.gg <- join(states.fort, states.df,by="id")
rm(states,bs,states.df,states.fort,dirs)
gc()      

# Get states legend:
stateplot <- ggplot(states.gg) + 
  geom_point(data=states.gg, aes(long, lat, color=hole),fill='white',shape=22,size=11,show_guide=TRUE) +
  scale_color_manual(name=" ",values='black',guide=guide_legend(label.theme=element_text(color='black', size=12,angle=0)),label='State Boundary')+ 
  theme(legend.key=element_rect(fill="white"),legend.text=element_text(size=12))+
  guides(colour = guide_legend(title = NULL))
#stateplot
lwd = 3   # Set line width
g = ggplotGrob(stateplot); dev.off()  # Get the plot grob
# Get the row number of the legend in the layout
rn <- which(g$layout$name == "guide-box")
# Extract the legend
legend <- g$grobs[[rn]]
# Get the legend keys
pointGrobs = which(grepl("points", legend$grobs[[1]]$grobs))
# Set line width
for (n in pointGrobs) legend$grobs[[1]]$grobs[[n]]$gp$lwd = lwd
stateleg <- legend$grobs[[1]]
rm(g,rn,legend,pointGrobs,stateplot,n,lwd); gc()

# Get Forest Layer (takes close to 20 minutes on FS desktop computer) ##########################################
FSbounds <- readOGR(paste0(mdir,'Forest_boundaries'),'S_USA.AdministrativeForest')
FSbounds@data$id <- rownames(FSbounds@data) 
FSbounds.df <- as.data.frame(FSbounds)
FSbounds.fort <- fortify(FSbounds, region="id")
FSbounds.ggg <- join(FSbounds.fort, FSbounds.df,by="id")
rm(FSbounds,FSbounds.df,FSbounds.fort); gc()
fsnames <- unique(FSbounds.ggg$FORESTNAME)

# Get Logos:
library(jpeg)
fsrd <- readJPEG('H:/MACA_futures/logos/fsrd.jpg')
fsrd <- rasterGrob(fsrd, interpolate=TRUE)
logos <- readJPEG('H:/MACA_futures/logos/NFCCMlogo.jpg')
logos <- rasterGrob(logos, interpolate=TRUE)

urlgrob <- textGrob(projurl, x = unit(0.45, "npc"), y = unit(0.8, "npc"),just = "centre", default.units = "npc",gp = gpar(fontface=3))

justify <- function(x, hjust="center", vjust="center", draw=TRUE){
  w <- sum(x$widths)
  h <- sum(x$heights)
  xj <- switch(hjust,center = 0.5,left = 0.5*w,right=unit(1,"npc") - 0.5*w)
  yj <- switch(vjust,center = 0.5,bottom = 0.5*h,top=unit(1,"npc") - 0.5*h)
  x$vp <- viewport(x=xj, y=yj)
  if(draw) grid.draw(x)
  return(x)
}

###################### FOR EACH FOREST:::::
for (fff in 1:length(fsnames)){
  print(paste0(fff,',  ',fsnames[fff]))
  forestnm <- fsnames[fff]
  forestii <- which(FSbounds.ggg$FORESTNAME==forestnm)
  fs <- FSbounds.ggg[forestii,]
  mbbox <- c(min(fs$long),min(fs$lat),max(fs$long),max(fs$lat))+c(-.2,-.2,.2,.2)  
  mbbox[4] <- pmin(mbbox[4],49.2) # avoid showing too much of canada
  ww <- mbbox[3]-mbbox[1]
  hh <- mbbox[4]-mbbox[2]
  fns <- gsub(',','',gsub('NationalForestsin','NF',gsub('[.]','',gsub('-','',gsub(' ','',as.character(forestnm))))))
  cdat <- cust[which(cust$ForestName==fns),]
  aa <- which(A1df2a$latvec>(mbbox[2]-.1) & A1df2a$latvec<(mbbox[4]+.1) & A1df2a$lonvec>(mbbox[1]-.1) & A1df2a$lonvec<(mbbox[3]+.1))
  aa2 <- which(A1df2$latvec>(mbbox[2]-.1) & A1df2$latvec<(mbbox[4]+.1) & A1df2$lonvec>(mbbox[1]-.1) & A1df2$lonvec<(mbbox[3]+.1))
  aan <- which(A1_nosnow$latvec>(mbbox[2]-.1) & A1_nosnow$latvec<(mbbox[4]+.1) & A1_nosnow$lonvec>(mbbox[1]-.1) & A1_nosnow$lonvec<(mbbox[3]+.1))
  
  if (length(aa)>0){ #if there is historical snow within the bounding box then proceed, otherwise go to next forest
    # for absolute changes:
    mx <- pmax(0,max(A1df2a$pveca[aa],na.rm=T))
    mn <- min(A1df2a$pveca[aa],na.rm=T)
    cola <- rev(matlab.like(112))[1:(63+round(-mx/mn*63))]#cols[1:(66+round(-mx/mn*66))]
    brka <- getbreaks(mn,mx)
    
    # for percent change
    mx2 <- pmax(max(A1df2$pvec[aa2],na.rm=T),0)
    if (length(aan)>0){ # if there are any 100% declines
      mn2 <- -100
    } else {
      mn2 <- min(A1df2$pvec[aa2],na.rm=T)
    }
    colp <- rev(matlab.like(112))[1:(63+round(-mx2/mn2*63))]#cols[1:(66+round(-mx/mn*66))]
    brkp <- getbreaks(mn2,mx2)
    
    
    # Get basemap
    gm <- get_stamenmap(bbox=mbbox,maptype="terrain-background",zoom=8)  # using bbox in get_stamenmap seems to get better resolution
    gmnrow <- nrow(gm)  
    gmbw <- colSums(col2rgb(gm)*c(0.2126,0.7152,0.0722))
    gmbw <- sqrt(sqrt(sqrt(gmbw)))
    gmbw <- as.numeric((gmbw-(min(gmbw)))*(255/(max(gmbw-(min(gmbw)))))/255.5) # rescale to increase contrast
    newhex <- rgb(red=gmbw,green=gmbw,blue=gmbw)  
    gm3 <- matrix(gm,nrow=1)
    for (ii in 1:length(gm3)){
      gm3[ii] <- which.max(col2rgb(gm3[ii]))
    }
    bb <- attr(gm,"bb")
    gm <- matrix(gm,nrow=1)
    newhex <- matrix(newhex,nrow=1)
    newhex[which(gm3=='3')] <- gm[which(gm3=='3')]
    gm <- matrix(newhex,nrow=gmnrow)
    class(gm) <- c("ggmap","raster")
    attr(gm,"bb")<- bb
    rm(newhex,gmbw,gmnrow,gm3)
    
    
    #gm <- get_googlemap(c(mean(mbbox[c(1,3)]),mean(mbbox[c(2,4)])),zoom=round(10-plotarea/1.7), maptype="terrain",color="bw",
    #                    size = c(640, 640), scale = 2, path = "&style=feature:all|element:labels|visibility:off")
    center <- c(mean(mbbox[c(1,3)]),mean(mbbox[c(2,4)]))
    latr <- mbbox[4]-mbbox[2]
    lonr <- mbbox[3]-mbbox[1]
    pad <- .02*pmax(latr,lonr)
    mpad <- mean(latr,lonr)*.04
    if (lonr < .8){
      ddist <- 5
    } else if (lonr >=.8 & lonr< 2){
      ddist <- 15
    } else if (lonr>=2 & lonr < 4){
      ddist <- 20
    } else if (lonr>=4 & lonr<6){
      ddist <- 30
    } else {
      ddist <- 50
    }
    rat <- lonr/latr
    norcorner <- as.character(cdat$Corner)
    if (norcorner =='topright'){
      anc <- data.frame(x=mbbox[3]-lonr*.03,y=mbbox[4]-rat*.03)
      stb <- 1
    } else if (norcorner== 'topleft'){
      anc <- data.frame(x=mbbox[1]+lonr*.03,y=mbbox[4]-rat*.03)
      stb <- 1
    } else if (norcorner=='bottomright'){
      anc <- data.frame(x=mbbox[3]-lonr*.03,y=mbbox[2]+rat*.07)
      stb <- 0
    } else if (norcorner=='bottomleft'){
      anc <- data.frame(x=mbbox[1]+lonr*.03,y=mbbox[2]+rat*.07)
      stb <- 0
    }
    
    sb <-  scalebar2(data=NULL,location=norcorner,dist=ddist,st.bottom=stb,st.size=3.5, #height=.02,st.dist=0.021,
                     dd2km=T,model="WGS84",x.min=mbbox[1],x.max=mbbox[3],y.min=mbbox[2],y.max=mbbox[4],anchor = anc,facet.var = NULL,facet.lev = NULL)
    
    cloc <- c(mean(c(sb[[3]]$data[1,1],sb[[3]]$data[2,1])),sb[[3]]$data[2,2])
    mpad <- .13*abs(sb[[3]]$data[1,1]-sb[[3]]$data[2,1])
    if (norcorner== 'topright' | norcorner == 'topleft'){
      norloc <- c(cloc[1]-mpad*.75,cloc[1]+mpad*.75,cloc[2],cloc[2]-mpad*2)
    } else {
      norloc <- c(cloc[1]-mpad*.75,cloc[1]+mpad*.75,cloc[2],cloc[2]+mpad*2)
    }
    
    
    #### PERCENT CHANGE ####
    # can use ggmap baselayer with geom_tile if the area is small enough it seems...
    var <- paste0("Percent Change in April 1 SWE, historical to 2080s RCP8.5")
    titleex <- bquote(atop(bold(.(as.character(forestnm))),atop(italic(.(as.character(var))))))
    
    if (mn2== -100){ # if there are any 100% declines then..
      ggp <-  
        ggmap(gm, base_layer=ggplot(aes(x=long,y=lat),data=states.gg),extent="normal",maprange=FALSE)+ 
        coord_cartesian(ylim=mbbox[c(2,4)],xlim=mbbox[c(1,3)]) +
        geom_tile(data=A1df2,aes(x=lonvec,y=latvec,fill=pvec),colour=NA,alpha=0.8) +  
        geom_tile(data=A1_nosnow,aes(x=lonvec,y=latvec),fill=NA,color='darkred',size=0.4)+
        geom_polygon(inherit.aes=FALSE, data=states.gg, aes(x=long, y=lat, group=group),color='black',show_guide=FALSE, fill=NA, size=1.4) +
        geom_polygon(inherit.aes=FALSE, data=fs, aes(x=long, y=lat, group=group), color="chartreuse4", fill=NA,size=1.4)+  
        scale_fill_gradientn(colours=colp,name='Percent change \nApril 1 SWE (%)',breaks=as.numeric(brkp),labels=brkp,limits=c(-99.999,mx2),
                             guide=guide_colorbar(order=1,barwidth=1.4,barheight=7,title.theme=element_text(size=12,angle=0),label.theme=element_text(size=11,angle=0)))+
        labs(title=titleex)+ annotation_raster(symbol,xmin=norloc[1],xmax=norloc[2],ymin=norloc[3],ymax=norloc[4])+
        geom_point(data=dummy, aes(lon, lat, color=factor(No)),fill=NA,pch=22,size=11,show_guide=TRUE,alpha=0.8) +
        scale_color_manual(name=" ",values='darkred',guide=guide_legend(label.theme=element_text(color='black', 
                                                                                                 size=12,angle=0),order=2),label='100% decline        ')+guides(colour = guide_legend(title = NULL)) +
        theme(legend.key=element_rect(fill="white"),axis.text=element_text(color="black"),title=element_text(size=16),legend.text=element_text(size=11),
              #plot.title = element_text(family = "Trebuchet MS", color="black", face="bold", size=15),
              axis.title = element_text(color="#666666", face="italic", size=10))+
        labs(y='',x='') + theme(aspect.ratio=hh/ww)+sb #this resizes the plot area to match the lat and lon range
      #ggp
      
    } else {
      ggp <-  
        ggmap(gm, base_layer=ggplot(aes(x=long,y=lat),data=states.gg),extent="normal",maprange=FALSE)+ 
        coord_cartesian(ylim=mbbox[c(2,4)],xlim=mbbox[c(1,3)]) +
        geom_tile(data=A1df2,aes(x=lonvec,y=latvec,fill=pvec),colour=NA,alpha=0.8) +  #
        #geom_tile(data=S1_nosnow,aes(x=lonvec,y=latvec),fill='darkgray',color=NA,alpha=0.8) +
        geom_polygon(inherit.aes=FALSE, data=states.gg, aes(x=long, y=lat, group=group),color='black',show_guide=FALSE, fill=NA, size=1.4) +
        geom_polygon(inherit.aes=FALSE, data=fs, aes(x=long, y=lat, group=group), color="chartreuse4", fill=NA,size=1.4)+  
        scale_fill_gradientn(colours=colp,name='Percent change \nApril 1 SWE (%)',breaks=as.numeric(brkp),labels=brkp,limits=c(mn2,mx2),
                             guide=guide_colorbar(order=1,barwidth=1.4,barheight=7,title.theme=element_text(size=12,angle=0),label.theme=element_text(size=11,angle=0)))+
        labs(title=titleex)+annotation_raster(symbol,xmin=norloc[1],xmax=norloc[2],ymin=norloc[3],ymax=norloc[4])+
        #geom_point(data=dummy, aes(lon, lat, color=factor(No)),fill='darkgrey',pch=22,size=11,show_guide=TRUE,alpha=0.8) +
        #scale_color_manual(name=" ",values='darkgrey',guide=guide_legend(label.theme=element_text(color='black', 
        #    size=12,angle=0),order=2),label='100% decline        ')+guides(colour = guide_legend(title = NULL)) +
        theme(legend.key=element_rect(fill="white"),axis.text=element_text(color="black"),title=element_text(size=16))+
        labs(x='',y='') + theme(aspect.ratio=hh/ww) +sb#this resizes the plot area to match the lat and lon range
      #ggp
    }
    mapobp <- ggplotGrob(ggp + theme(legend.position="none",plot.margin=unit(c(0, 0, 0, 0), 'lines')))
    
    #### ABSOLUTE CHANGE ####
    var <- paste0("Absolute Change in April 1 SWE, historical to 2080s RCP8.5")
    titleex <- bquote(atop(bold(.(as.character(forestnm))),atop(italic(.(as.character(var))))))
    gga <-  
      ggmap(gm, base_layer=ggplot(aes(x=long,y=lat),data=states.gg),extent="normal",maprange=FALSE)+ 
      coord_cartesian(ylim=mbbox[c(2,4)],xlim=mbbox[c(1,3)]) +
      geom_tile(data=A1df2a,aes(x=lonvec,y=latvec,fill=pveca),colour=NA,alpha=0.8) +  #
      geom_polygon(inherit.aes=FALSE, data=states.gg, aes(x=long, y=lat, group=group),color='black',show_guide=FALSE, fill=NA, size=1.4) +
      geom_polygon(inherit.aes=FALSE, data=fs, aes(x=long, y=lat, group=group), color="chartreuse4", fill=NA,size=1.4)+  
      scale_fill_gradientn(colours=cola,name='Absolute change \nApril 1 SWE (mm)',breaks=as.numeric(brka),labels=brka,limits=c(mn,mx),
                           guide=guide_colorbar(order=1,barwidth=1.4,barheight=7,title.theme=element_text(size=12,angle=0),label.theme=element_text(size=11,angle=0)))+
      labs(title=titleex)+annotation_raster(symbol,xmin=norloc[1],xmax=norloc[2],ymin=norloc[3],ymax=norloc[4])+
      theme(legend.key=element_rect(fill="white"),axis.text=element_text(color="black"),title=element_text(size=16))+
      labs(x='',y='') + theme(aspect.ratio=hh/ww) +sb#this resizes the plot area to match the lat and lon range
    #gga
    mapoba <- ggplotGrob(gga + theme(legend.position="none",plot.margin=unit(c(1, 0, .1, 0), 'lines')))
    
    
    if (fff==1){
      # Get forest legend:
      fsplot <- ggplot(fs) + 
        geom_point(data=fs, aes(x=long, y=lat, color=FORESTNUMB, stroke=22), shape=22,size=11,show_guide=TRUE) +
        scale_color_manual(name=" ",values='chartreuse4',guide=guide_legend(label.theme=element_text(color='black', size=12,angle=0)),
                           label='National Forest \nBoundary')+
        theme(legend.key=element_rect(fill="white"),legend.text=element_text(size=12))+
        guides(colour = guide_legend(title = NULL,stroke=22))
      #fsplot
      lwd = 3   # Set line width
      g = ggplotGrob(fsplot); dev.off()  # Get the plot grob
      indices <- c(subset(g$layout, name == "guide-box", select = t:r))
      rn <- which(g$layout$name == "guide-box")
      legend <- g$grobs[[rn]]
      pointGrobs = which(grepl("points", legend$grobs[[1]]$grobs))
      for (n in pointGrobs) legend$grobs[[1]]$grobs[[n]]$gp$lwd = lwd
      fsleg <- legend$grobs[[1]]
      rm(g,indices,rn,legend,pointGrobs,fsplot); gc()
      
      # Get legends:
      g_legend<-function(a.gplot){
        tmp <- ggplot_gtable(ggplot_build(a.gplot))
        leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
        legend <- tmp$grobs[[leg]]
        return(legend)}    
    } 
    
    
    # Save Map:
    fw <- cdat$FileWidth
    fh <- cdat$FileHeight
    if (is.na(fw)){
      rr <- 10/pmax(ww,hh)
      fw <- ww*rr
      fh <- hh*rr
    }
    forestnm2 <- gsub('[.]','',gsub(',' , '', (gsub(' ','_',forestnm))))
    
    
    e <- gtable(unit(fw,"in"),unit(c(1,.5),"in"))
    ee <- gtable_add_grob(e,logos,1,1)
    eee <- gtable_add_grob(ee,urlgrob,2,1)
    
    d <- gtable(unit(c(fw,2),"in"),unit(1.5,"in"))
    dd <- gtable_add_grob(d,eee,1,1)
    logogrob <- gtable_add_grob(dd,fsrd,1,2)
    
    
    ###### for absolute change A1SWE:
    cb<-colorbar2sided(cola,mn,mx,brka,paste0('Absolute Change in \n April 1 SWE'),convert=3,type='difference')
    a <- gtable(unit(4, c("cm")), unit(c(8,2,2), "cm"))
    a <- gtable_add_grob(a,cb,1,1)
    a <- gtable_add_grob(a,justify(stateleg,"right","top"),2,1)
    leg <- gtable_add_grob(a,justify(fsleg,"right","top"),3,1)
    
    b <- gtable(unit(c(fw,2), "in"), unit(c(fh), "in"))
    b <- gtable_add_grob(b,mapoba,1,1)
    b <- gtable_add_grob(b,leg,1,2)
    
    c <- gtable(unit(fw+2,"in"),unit(c(fh,1.5),"in"))
    c <- gtable_add_grob(c,b,1,1)
    hplot <- gtable_add_grob(c,logogrob,2,1)
    rm(a,b,c,cb,leg); gc()
    
    filenm <- paste0(mdir,'MACA_futures/Snow/Maps/A1SWE_abschange/',forestnm2,'_A1SWE_abschange.pdf')
    cairo_pdf(filenm,width=fw+2,height=fh+2)
    grid.arrange(hplot,ncol=1,nrow=1)
    dev.off()
    
    
    ###### for percent change A1SWE:
    cb <- g_legend(ggp)
    a <- gtable(unit(4, c("cm")), unit(c(8,2,2), "cm"))
    a <- gtable_add_grob(a,cb,1,1)
    a <- gtable_add_grob(a,justify(stateleg,"right","top"),2,1)
    leg <- gtable_add_grob(a,justify(fsleg,"right","top"),3,1)
    
    b <- gtable(unit(c(fw,2), "in"), unit(c(fh), "in"))
    b <- gtable_add_grob(b,mapobp,1,1)
    b <- gtable_add_grob(b,leg,1,2)
    
    c <- gtable(unit(fw+2,"in"),unit(c(fh,1.5),"in"))
    c <- gtable_add_grob(c,b,1,1)
    hplot <- gtable_add_grob(c,logogrob,2,1)
    rm(a,b,c,cb,leg); gc()
    
    filenm <- paste0(mdir,'MACA_futures/Snow/Maps/A1SWE_percentchange/',forestnm2,'_A1SWE_percentchange.pdf')
    cairo_pdf(filenm,width=fw+2,height=fh+2)
    grid.arrange(hplot,ncol=1,nrow=1)
    dev.off()
    
    
    ############## MAY NEED TO MAKE ADDITIONAL MODIFICATIONS TO PERCENT CHANGE GTABLE TO ACCOMODATE EXTRA LEGEND FOR 100% DECLINE
    
    
    
  }
} #end for each forest












