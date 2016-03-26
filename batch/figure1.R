##
## Normals analysis
##

## Helper functions
f.pvalue <- function(dat,mod,mod0){
  # This is a function for performing
  # parametric f-tests on the data matrix
  # dat comparing the null model mod0
  # to the alternative model mod. 
  n <- dim(dat)[2]
  m <- dim(dat)[1]
  df1 <- dim(mod)[2]
  df0 <- dim(mod0)[2]
  p <- rep(0,m)
  Id <- diag(n)
  
  resid <- dat %*% (Id - mod %*% solve(t(mod) %*% mod) %*% t(mod))
  resid0 <- dat %*% (Id - mod0 %*% solve(t(mod0) %*% mod0) %*% t(mod0))
  
  rss1 <- resid^2 %*% rep(1,n)
  rss0 <- resid0^2 %*% rep(1,n)
  
  fstats <- ((rss0 - rss1)/(df1-df0))/(rss1/(n-df1))
  p <-  1-pf(fstats,df1=(df1-df0),df2=(n-df1))
  return(p)
}


library(RColorBrewer)
mypar <- function(a=1,b=1,brewer.n=8,brewer.name="Dark2",...){
 par(mar=c(2.5,2.5,1.6,1.1),mgp=c(1.5,.5,0))
 par(mfrow=c(a,b),...)
 palette(brewer.pal(brewer.n,brewer.name))
}


myplclust <- function( hclust, lab=hclust$labels, lab.col=rep(1,length(hclust$labels)), hang=0.1,...){
 ## modifiction of plclust for plotting hclust objects *in colour*!
 ## Copyright Eva KF Chan 2009
 ## Arguments:
 ##    hclust:    hclust object
 ##    lab:        a character vector of labels of the leaves of the tree
 ##    lab.col:    colour for the labels; NA=default device foreground colour
 ##    hang:     as in hclust & plclust
 ## Side effect:
 ##    A display of hierarchical cluster with coloured leaf labels.
 y <- rep(hclust$height,2)
 x <- as.numeric(hclust$merge)
 y <- y[which(x<0)]
 x <- x[which(x<0)]
 x <- abs(x)
 y <- y[order(x)]
 x <- x[order(x)]
 plot( hclust, labels=FALSE, hang=hang, ... )
 text( x=x, y=y[hclust$order]-(max(hclust$height)*hang), labels=lab[hclust$order], col=lab.col[hclust$order], srt=90, adj=c(1,0.5), xpd=NA, ... )
}


# Load the data

load("bladder-cancer.rda")
dat <- mat
grp <- outcome
year <- batch

Index <- grp=="Normal"

dat <- dat[,Index]
grp <- grp[Index]
year <- year[Index]


# Cluster the normals and color by date

dd <- dist(t(dat))
hh <- hclust(dd,method="average")

mypar()
pdf(file="normalcluster.pdf",height=7,width=7)
myplclust(hh,lab=rep("Normal",8),lab.col=as.numeric(as.factor(year)),main="",lwd=2,cex=1.8,ylab="",xlab="",ann=F,las=1)
dev.off()


# Load in the raw data

library(affy)

tab=read.csv("bladdercels/bladdertab.csv",as.is=TRUE)
celfiles <- tab$filename
ab1 <- ReadAffy(filenames=celfiles,celfile.path = "bladdercels")


# Create the un-normalized normal bladder sample boxplots
rdat <- log2(exprs(ab1)[,order(as.numeric(as.factor(year)))])
mn <- min(rdat)
mx <- max(rdat)
pdf(file="unormal.pdf")
boxplot(rdat,range=0,xaxt="n",xlab="Sample",ylab="Expression",col=as.numeric(as.factor(year))[order(as.numeric(as.factor(year)))],ylim=c(mn,mx))
dev.off()


# Create the normalized normal bladder sample boxplots
mn <- min(dat)
mx <- max(dat)
pdf(file="nnormal.pdf")
boxplot(dat[,order(as.numeric(as.factor(year)))],range=0,xaxt="n",xlab="Sample",ylab="Expression",col=as.numeric(as.factor(year))[order(as.numeric(as.factor(year)))],ylim=c(mn,mx))
dev.off()


# Find some features affected by batch
mod <- model.matrix( ~as.factor(year))
mod0 <- cbind(mod[,1])
pp <- f.pvalue(dat,mod,mod0)
pp.adj <- p.adjust(pp,method="BH")

mm <- abs(rowMeans(dat[,year==2]) - rowMeans(dat[,year==3]))
aa <- which(mm > 1.5 & pp < 0.0005)

tmp <- c(1,2,3,4,5,15,16,17,8,12)
pdf(file="test1.pdf")
plot(dat[aa[1],],col=1,pch=19,cex=1.2,xlab="Array",xaxt="n",ylab="Expression",ylim=c(4,11),type="n")

for(i in 1:10){
lines(dat[aa[i],order(year)],col="darkgrey")
points(dat[aa[i],order(year)],col=as.numeric(as.factor(year))[order(as.numeric(as.factor(year)))],pch=tmp[i],cex=1.7)
}
dev.off()

