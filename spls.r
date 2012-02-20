# The data is transferred in 
# -temp_data.mat
# ---trainx
# ---trainy
# -temp_params.mat
# ---ncomp - number of pls components
# ---nfeats - number of features to select
#
# The result is stored in
# -temp_output.mat
# ---feats - coefficients which have to be thresholded
# ---etas - sparsity coefficients

# Load libraries
library('R.matlab')
#library('mixOmics')
library('spls')

# temp_data.mat will most likely be symlinked to actual data file
data<-readMat('temp_data.mat')
## to add rand to data$X
#data$X <- data$X + matrix(rexp(length(data$X)),nrow=nrow(data$X))

# should contain the variable 'ncomp' and 'nfeats'
params<-readMat('temp_params.mat')

# Perform feature selection with sparse-PLS of Le Cao et al.
#result<-splsda(data$X,factor(data$Y),ncomp=params.ncomp,keepX=rep(params.nfeats,params.ncomp))
# Get the selected features
#select.var(result,comp=10)$name

# Perform feature selection with sparse PLS of Chun and Keles.
initNumFeats <- dim(data$trainX)[1]
eta_curr <- 0.99
selected_feats <- matrix(,ncol=dim(data$trainx)[2])
etas <- array()
while (eta_curr >= 0.1) {
  result <- spls(data$trainx,data$trainy,eta=eta_curr,K=params$ncomp)
  etas <- c(etas,eta_curr)
  eta_curr <- eta_curr - 0.01
  fs <- coef(result)
  features <- which(fs!=0)
  if (length(features) > max(params$nfeats)){
    eta_curr <- 0
  }
  selected_feats <- rbind(selected_feats,t(fs))
}
etas <- etas[2:length(etas)]
selected_feats <- selected_feats[2:nrow(selected_feats),]
writeMat('temp_output.mat',etas=etas,feats=selected_feats)