homedir="/amber1/scratch/temp/ririzarr/tcga/affy"
dirs=list.files(homedir)
batchNames=as.numeric(gsub("broad.mit.edu_OV.HT_HG-U133A.Level_1.|.1002.0","",dirs))
O=order(batchNames)
dirs=dirs[O]
batchNames=batchNames[O]
library(affy)

files=vector("list",length(dirs))
for(i in seq(along=dirs)){
  tmpPath=file.path(homedir,dirs[i])
  fns=list.files(tmpPath)
  files[[i]]=fns[grep("[cC][eE][lL]",fns)]
}

nfiles=sapply(files,length)
starts=c(0,cumsum(nfiles[-length(nfiles)]))
cnames=vector("character",sum(nfiles))
batch=factor(rep(seq(along=files),nfiles))

filenames=vector("character",sum(nfiles))
for(i in seq(along=dirs)){
  tmpPath=file.path(homedir,dirs[i])
  fns=files[[i]]
  filenames[starts[i]+seq(along=fns)]=file.path(tmpPath,fns)
}

##No dates in the cel files!! what the f?
##dates=vector("character",(length(filenames)))
##for(i in seq(along=filenames)){
##    dates[i]=celfileDate(filenames[i])
##}

e=justRMA(filenames=filenames,celfile.path="/")
mat=exprs(e)

##tmp=genefilter::rowFtests(mat,batch)
save(mat,batch,batchNames,file="affy-expr.rda")
