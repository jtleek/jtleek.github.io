homedir="/amber1/scratch/temp/ririzarr/tcga/methylation"
dirs=list.files(homedir)

batchNames=gsub("jhu-usc.edu_OV.HumanMethylation27.","",dirs)
tmp=t(sapply(strsplit(batchNames,"\\."),function(x) as.numeric(x[1:2])))
##pick the lastest replicate
keepIndex=sapply(split(1:nrow(tmp),tmp[,1]),function(ind)ind [which.max(tmp[ind,2])])
dirs=dirs[keepIndex]
batchNames=batchNames[keepIndex]

files=vector("list",length(dirs))
ngenes=27578
for(i in seq(along=dirs)){
  tmpPath=file.path(homedir,dirs[i])
  fns=list.files(tmpPath)
  files[[i]]=fns[grep("lvl-2",fns)]
}

nfiles=sapply(files,length)
starts=c(0,cumsum(nfiles[-length(nfiles)]))
betas=matrix(NA,ngenes,sum(nfiles))
cnames=vector("character",sum(nfiles))
batch=factor(rep(seq(along=files),nfiles))
for(i in seq(along=dirs)){
  cat(i)
  tmpPath=file.path(homedir,dirs[i])
  fns=files[[i]]
  for(j in seq(along=fns)){
    cat(".")
    ###Get the sample name
    tmp=strsplit(readLines(file.path(tmpPath,fns[j]),n=1),"\t")
    cnames[ j+starts[i] ]=tmp[[1]][2]

    ##now get the Beta values
    tmp=read.delim(file.path(tmpPath,fns[j]),skip=1,check.names=FALSE,as.is=TRUE)
    betaIndex=grep("[bB]eta",names(tmp)) ##the column name change!!
    betas[,j+starts[i]]=tmp[,betaIndex]

    ###check "gene" names in same order
    if(i==1 & j==1) gnames=tmp[,"CompositeElement REF"] else if(!identical(gnames,tmp[,"CompositeElement REF"])) stop("Genes not in order")
  }
  cat("\n")
}
colnames(betas)=cnames
rownames(betas)=gnames

save(betas,batch,batchNames,file="betas.rda")
###quick batch effect calculations
##fist look at NAs by batch
nna=colMeans(is.na(betas)) *100
pdf("tcga-meth-batch-effect.pdf",width=11,height=8)
mypar()
plot(nna,xlab="array",ylab="%NA",main="%NA per array (red lines divde batches)",xaxt="n")
abline(v=starts,col=2)
axis(side=1,starts,batchNames,las=3)
dev.off()
  
