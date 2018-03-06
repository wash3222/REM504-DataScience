#####Fig 1--> Conceptual stages and moisture profile

a=read.csv(file.choose())

a$t=as.POSIXct(a$t)
times=as.POSIXct(c("4.1.2015","5.1.2015","6.1.2015","7.1.2015",
                   "8.1.2015","9.1.2015","10.1.2015","11.1.2015","12.1.2015","1.1.2016","2.1.2016","3.1.2016","4.1.2016","5.1.2016","6.1.2016")
                 ,format="%m.%d.%Y")
time.labels=c("Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun")
less.labels=time.labels
less.labels[which(index(time.labels)%%2==1)]=NA
index=c(707,4439,6384,9553,16528,17863)
stages=c(1,2,3,4,5,1)

{
  tiff("conceptual.test.tif",width=6.5,height=4.332,res=300,units="in",pointsize=12)
{
  par(fig=c(0,1,.0,.36),mai=c(.5,.85,0,.85),mgp=c(3,.4,0))
  plot(a$v~a$t,t="l",lwd=1.89,axes=F,ylab="",xlab="",ylim=c(0,32.6),yaxs="i",col=rgb(0,0,1,.9))
  axis(1,tck=.05,at=c(times),labels=c(less.labels))
  axis(4,tck=.05,las=2,at=seq(0,40,10))
  mtext(side=1,text="Month",line=1.5)
  mtext(side=4,text="VWC (%) ",line=1.5)
  text(a$t[length(a$t)*.005],22,labels="(b)",font=2)
  
  par(fig=c(0,1,.0,.37),mai=c(.5,.85,0,.85),mgp=c(3,.4,0),new=T)
  plot(a$p~a$t,t="n",lwd=1.89,axes=F,ylab="",xlab="",ylim=c(0,2.2),yaxs="i")
  axis(2,tck=.05,las=2,at=seq(0,2.5,1))
  polygon(a$t,a$p,col=rgb(.3,.3,.3,.4),border=F)
  mtext(side=2,text="Rain equivalent\n (mm) ",line=1.5)
  
  
  par(fig=c(0,1,.4,1),mai=c(0,.85,.05,.85),mgp=c(3,.4,0),new=T)
  plot(a$sm.av~a$t,axes=F,lwd=1.89,t="l",xlab="",ylab="",yaxt="n",ylim=c(0,2),xaxt="n",yaxs="i")
  
  axis(1,tck=.02,at=c(times),F)
  axis(2,tck=.00,las=2,labels=F,at=seq(0,1.8,1.8))
  mtext(side=2,text="ΔC\n",line=1.5)
  segments(x0=a$t[index],x1=a$t[index],y0=c(0,0,0,0,0,0),y1=rep(1.6,6),lty=3,col=rgb(.4,.4,.4,.5))
  text(a$t[length(a$t)*.005],1.5,labels="(a)",font=2)
  text(a$t[index],1.65,labels=stages,font=1)
  
  
}
dev.off()
}

{
  svg("conceptual.test.svg",width=6.5,height=4.332,pointsize=12,family="sans")
  {
    par(fig=c(0,1,.0,.36),mai=c(.5,.85,0,.85),mgp=c(3,.4,0))
    plot(a$v~a$t,t="l",lwd=1.89,axes=F,ylab="",xlab="",ylim=c(0,32.6),yaxs="i",col=rgb(0,0,1,.9))
    axis(1,tck=.05,at=c(times),labels=c(less.labels))
    axis(4,tck=.05,las=2,at=seq(0,40,10))
    mtext(side=1,text="Month",line=1.5)
    mtext(side=4,text="VWC (%) ",line=1.5)
    text(a$t[length(a$t)*.005],22,labels="(b)",font=2)
    
    par(fig=c(0,1,.0,.37),mai=c(.5,.85,0,.85),mgp=c(3,.4,0),new=T)
    plot(a$p~a$t,t="n",lwd=1.89,axes=F,ylab="",xlab="",ylim=c(0,2.2),yaxs="i")
    axis(2,tck=.05,las=2,at=seq(0,2.5,1))
    polygon(a$t,a$p,col=rgb(.3,.3,.3,.4),border=F)
    mtext(side=2,text="Rain equivalent\n (mm) ",line=1.5)
    
    
    par(fig=c(0,1,.4,1),mai=c(0,.85,.05,.85),mgp=c(3,.4,0),new=T)
    plot(a$sm.av~a$t,axes=F,lwd=1.89,t="l",xlab="",ylab="",yaxt="n",ylim=c(0,2),xaxt="n",yaxs="i")
    
    axis(1,tck=.02,at=c(times),F)
    axis(2,tck=.00,las=2,labels=F,at=seq(0,1.8,1.8))
    mtext(side=2,text="ΔC\n",line=1.5)
    segments(x0=a$t[index],x1=a$t[index],y0=c(0,0,0,0,0,0),y1=rep(1.6,6),lty=3,col=rgb(.4,.4,.4,.5))
    text(a$t[length(a$t)*.005],1.5,labels="(a)",font=2)
    text(a$t[index],1.65,labels=stages,font=1)
    
  }
  dev.off()
}
