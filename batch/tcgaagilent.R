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

load("agilent.rda")

dat <- mat[,-weirdIndex]
naind <- !is.na(dat) %*% rep(1,dim(dat)[2])
dat <- dat[naind,]
year <- dates[-weirdIndex]
bat <- batch[-weirdIndex]



# Assumes you start with a matrix of genes called "dat", a group variable "grp",
# and a year variable "year" (you could replace year with batch)

library(corpcor)

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



