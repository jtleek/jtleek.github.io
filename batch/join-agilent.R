homedir="/amber1/scratch/temp/ririzarr/tcga/agilent"
dirs=list.files(homedir)

batchNames=gsub("unc.edu_OV.AgilentG4502A_07_3.","",dirs)
tmp=t(sapply(strsplit(batchNames,"\\."),function(x) as.numeric(x[1:2])))
##pick the lastest replicate
keepIndex=sapply(split(1:nrow(tmp),tmp[,1]),function(ind)ind [which.max(tmp[ind,2])])
dirs=dirs[keepIndex]
batchNames=batchNames[keepIndex]

files=vector("list",length(dirs))
rawfiles=vector("list",length(dirs))
for(i in seq(along=dirs)){
  tmpPath=file.path(homedir,dirs[i])
  fns=list.files(tmpPath)
  fns=fns[grep("US82800149",fns)]
  files[[i]]=fns[grep("logratio.gene",fns)]
  rawfiles[[i]]=fns[-grep("out.logratio",fns)]
}

##check
if(any(!sapply(seq(along=files),function(i)
  identical(gsub("_lmean.out.logratio.gene.tcga_level3.data.txt","",files[[i]]),
            rawfiles[[i]])))) stop("raw and processed names don't match")
  
nfiles=sapply(files,length)
starts=c(0,cumsum(nfiles[-length(nfiles)]))
ngenes=17814 ##got this by hand... reading in one file and counting.
##ngenes=90797 ##this one is for probes
mat=matrix(NA,ngenes,sum(nfiles))
cnames=vector("character",sum(nfiles))
dates=vector("character",sum(nfiles))
batch=factor(rep(seq(along=files),nfiles))
for(i in seq(along=dirs)){
  cat(i)
  tmpPath=file.path(homedir,dirs[i])
  fns=files[[i]]
  rawfns=rawfiles[[i]]
  for(j in seq(along=fns)){
    tmp=strsplit(readLines(file.path(tmpPath,fns[j]),n=1),"\t")
    cnames[ j+starts[i] ]=tmp[[1]][2]
    tmp=read.delim(file.path(tmpPath,fns[j]),skip=1,check.names=FALSE,as.is=TRUE)
##     if(i==1 & j==1) gnames=tmp[,1] else if(!identical(gnames,tmp[,1])) stop("SHIT") ##this line is for probes
     if(i==1 & j==1){
       gnames=tmp[,1]
       Index=1:ngenes
     } else{
       Index=match(tmp[,1],gnames)
       if(any(is.na(Index)) | any(duplicated(Index))) stop("genes don't match")
     }
    cat(".")
    mat[Index,j+starts[i]]=tmp[,2]
    ##get date
    tmp=strsplit(readLines(file.path(tmpPath,rawfns[j]),n=3)[3],"\t")[[1]][4]
    dates[j+starts[i]]=as.character(as.Date(strsplit(tmp," ")[[1]][1],format="%m-%d-%Y"))
  }
  cat("\n")
}
colnames(mat)=cnames
rownames(mat)=gnames

###quick batch effect calculations
##fist look at NAs by batch
keepIndex=which(rowSums(is.na(mat))==0)
x=mat[keepIndex,]
Indexes=split(1:ncol(mat),batch)
weirdIndex=sapply(Indexes[-1],function(i)
  i[which.max(Biobase::rowMedians(as.matrix(dist(t(x[,i])))))])

save(mat,dates,batch,batchNames,weirdIndex,file="agilent.rda")


