library(corpcor)
library(affy)
source("http://rafalab.jhsph.edu/batch/myplclust.R")

##read-in array data
tab=read.csv("bladdercels/bladdertab.csv",as.is=TRUE)
eset=justRMA(filenames=tab$filename,celfile.path="bladdercels/")


###definde classes
outcome=tab[,8]
bt=tab[,5]
Index=which(outcome=="sTCC")
Cplus=grep("CIS",bt[Index])
outcome[Index]="sTCC-CIS"
outcome[Index[Cplus]]="sTCC+CIS"
outcome[49:57]<-"Biopsy"

##get expression matrix
mat=exprs(eset)

###get date
dates=vector("character",ncol(mat))
for(i in seq(along=dates)){
    tmp=affyio::read.celfile.header(file.path("bladdercels",tab$filenam[i]),info="full")$DatHeader
  dates[i]=strsplit(tmp,"\ +")[[1]][8]
}
dates=as.Date(dates,"%m/%d/%Y")

##divide dates into batches
batch=dates-min(dates);
batch=as.numeric(cut(batch,c(-1,10,75,200,300,500)))

##compute distance between and perform clustering 
mydist=dist(t(mat))
hc=hclust(mydist)
##make cluster. show outcome in text, batch in color
myplclust(hc,lab=outcome,lab.col=batch)
##one can also use muli-dimensional scaling
cmd=cmdscale(mydist)
plot(cmd,type="n")
text(cmd,outcome,col=batch)
##note the normals separate by date


##obtain singular value decomp 
s=fast.svd(mat-rowMeans(mat))

##how much variability explained by each component
plot(s$d^2/sum(s$d^2))
abline(h=0.10)
##note first two component explain almost half variability
##what do the correlate with?

##note correlation with batch
boxplot(split(s$v[,1],batch))
boxplot(split(s$v[,2],batch))

###and confounding between batch and outcome
table(outcome,batch)

###this amount of confounding is hard to fix.
###But we can try using sva or combat.
##sva
##http://www.biostat.jhsph.edu/~jleek/sva/
###or combat 
##http://jlab.byu.edu//ComBat/Download.html

