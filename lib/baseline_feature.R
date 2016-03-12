rm(list=ls())

setwd("/Users/Bianbian/GitHub/cycle3cvd-team-6/data/images")
library(grDevices)
library(e1071)
library(caret)
### Extract HSV
extract.features <- function(img){
  mat <- imageData(img)
  mat_rgb <- mat
  dim(mat_rgb) <- c(nrow(mat)*ncol(mat), 3)
  mat_hsv <- rgb2hsv(t(mat_rgb))
  nH <- 10
  nS <- 6
  nV <- 6
  # Caution: determine the bins using all images! The bins should be consistent across all images. The following code is only used for demonstration on a single image.
  hBin <- seq(0, 1, length.out=nH)
  sBin <- seq(0, 1, length.out=nS)
  vBin <- seq(0, 0.005, length.out=nV) 
  freq_hsv <- as.data.frame(table(factor(findInterval(mat_hsv[1,], hBin), levels=1:nH), 
                                  factor(findInterval(mat_hsv[2,], sBin), levels=1:nS), 
                                  factor(findInterval(mat_hsv[3,], vBin), levels=1:nV)))
  hsv_feature <- as.numeric(freq_hsv$Freq)/(ncol(mat)*nrow(mat)) # normalization
  return(hsv_feature)
}

### Read all listed on list.txt
labels <- read.table("../annotations/list.txt",stringsAsFactors = F)
obs<-dim(labels)[1]
X <- array(rep(0,obs*360),dim=c(obs,360))
for (i in 1:obs){
  tryCatch({
    img <- readImage(paste0(labels$V1[i],".jpg"))
  }, error =function(err){count=count+1},
  finally = {X[i,] <- extract.features(img)})
}
data_hsv<-as.data.frame(cbind(labels[,3],X))
data_hsv$V1<-as.factor(data_hsv$V1)

### Split to two sets
inTrain<-createDataPartition(data_hsv$V1,p=0.75,list=FALSE)
train<-data_hsv[inTrain,]
test<-data_hsv[-inTrain,]
save(train,file="train_data.RDS")
save(test,file="test_data.RDS")






