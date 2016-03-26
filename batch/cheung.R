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


# Load data and create group variable
dat <- read.table("full.data")
source("svfunctions.r")
jpt.names <- scan("JPT.cname.txt",what="character")
chb.names <- scan("CHB.cname.txt",what="character")
ceu.names <- scan("CEU_parents.txt",what="character")
nceu <- length(ceu.names)
njpt <- length(jpt.names)
nchb <- length(chb.names)
nas <- nchb + njpt
n <- nas + nceu

probes <- read.table("total.80.probes")
probes <- probes[,1]
dat <- dat[probes,]
names(dat) <- c(ceu.names,chb.names,jpt.names)
dat <- log(dat,base=2)
dat <- as.matrix(dat)

grp <- c(rep(0,nceu),rep(1,nas))


# Load the sex variable

ceu_sex <- read.table("./covfiles/CEU_sexinfo.txt",row.names=2)
jpt_sex <- read.table("./covfiles/JPT_sexinfo.txt",row.names=2)
chb_sex <- read.table("./covfiles/CHB_sexinfo.txt",row.names=2)

nms <- dimnames(dat)[[2]]
sex <- rep(0,n)
for(i in 1:nceu){
	sex[i] <- ceu_sex[(nms[i] == row.names(ceu_sex)),1]
}
for(i in 1:nchb){
	sex[(i + nceu)] <- chb_sex[(nms[( i + nceu)] == row.names(chb_sex)),1]
}
for(i in 1:njpt){
	sex[(i + nceu + nchb)] <- jpt_sex[(nms[(i + nceu + nchb)] == row.names(jpt_sex)),1]
}

# Load the year variable. 
yr <- read.table("year.txt")

year <- rep(0,dim(dat)[2])
for(i in 1:dim(dat)[2]){
	year[i] <- (yr[yr[,1] == colnames(dat)[i],2])[1]
}



# Assumes you start with a matrix of genes called "dat", a group variable "grp",
# and a year variable "year" (you could replace year with batch)

library(corpcor)

# Adjusted R^2 between grp & year

ct <- table(year,grp)
chisq.test(ct)$p.value


# Calculate p-values for year

mod <- model.matrix( ~as.factor(year))
mod0 <- cbind(mod[,1])
pp <- f.pvalue(dat,mod,mod0)
pp.adj <- p.adjust(pp,method="BH")

mean(pp.adj < 0.05)


# Calculate SVD

ss <- fast.svd(t(scale(t(dat),scale=F)),tol=0)

# Calculate p-values for svs 

mod <- model.matrix( ~ ss$v[,1:5])
mod0 <- cbind(mod[,1])
pp <- f.pvalue(dat,mod,mod0)
pp.adj <- p.adjust(pp,method="BH")

mean(pp.adj < 0.05)


# Find adjusted multiple R^2 for each sv with year (take the max)

cc <- rep(0,5)

for(i in 1:5){
  cc[i] <- summary(lm(ss$v[,i] ~ as.factor(year)))$adj.r.squared
}

max(cc)

# Find adjusted multiple R^2 for each sv with outcome (take the max)

cc <- rep(0,5)

for(i in 1:5){
  cc[i] <- summary(lm(ss$v[,i] ~ as.factor(grp)))$adj.r.squared
}

max(cc)




# Calculate p-values for group

mod <- model.matrix( ~ as.factor(grp))
mod0 <- cbind(mod[,1])
pp <- f.pvalue(dat,mod,mod0)
pp.adj <- p.adjust(pp,method="BH")

mean(pp.adj < 0.05)



