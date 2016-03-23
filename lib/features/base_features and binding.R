# install.packages("e1071")
# install.packages("caret")
# source("http://bioconductor.org/biocLite.R")
# biocLite()
# biocLite("EBImage")
# install.packages("grDevices")

library(EBImage)
library(grDevices)
library(e1071)
library(caret)

#   Set folder containing images
dir_images <- "/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/images/"
#   Set to project directory
setwd("/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/cycle3cvd-team-6")

# setwd("/Users/yueyingteng/Downloads/images")

### Extract HSV
extract.features <- function(img){
  mat <- imageData(img)
  # Convert 3d array of RGB to 2d matrix
  mat_rgb <- mat
  dim(mat_rgb) <- c(nrow(mat)*ncol(mat), 3)
  mat_hsv <- rgb2hsv(t(mat_rgb))
  nH <- 10
  nS <- 6
  nV <- 6
  # Caution: determine the bins using all images! The bins should be consistent across all images. 
  # The following code is only used for demonstration on a single image.
  hBin <- seq(0, 1, length.out=nH)
  sBin <- seq(0, 1, length.out=nS)
  vBin <- seq(0, 0.005, length.out=nV) 
  freq_hsv <- as.data.frame(table(factor(findInterval(mat_hsv[1,], hBin), levels=1:nH), 
                                  factor(findInterval(mat_hsv[2,], sBin), levels=1:nS), 
                                  factor(findInterval(mat_hsv[3,], vBin), levels=1:nV)))
  hsv_feature <- as.numeric(freq_hsv$Freq)/(ncol(mat)*nrow(mat)) # normalization
  return(hsv_feature)
}

## read image

image_names <- list.files(dir_images)
# corrupt <- c(-4, -6, -8, -140, -152, -2237, -2246, -2247, -2253, -2265, -2274, -2283, -2293, -2299, -6903, -6909)
# image_names <- image_names[corrupt]
# labels <- read.csv("/Users/yueyingteng/Downloads/labels.csv",stringsAsFactors = F)
# obs<-dim(labels)[1]
X <- array(rep(0,length(image_names)*360),dim=c(length(image_names),360))
for (i in 1:length(image_names)){
  tryCatch({
    img <- readImage(paste0(dir_images,image_names[i]))
  }, 
  error =function(err){print(i)},
  finally = {X[i,] <- extract.features(img)})
}
data_hsv<-as.data.frame(X)
# data_hsv<-as.data.frame(cbind(labels[,3],X))
# data_hsv<-unique(data_hsv)
# save(data_hsv,file="beseline feature.RData")
# data_hsv$V1<-as.factor(data_hsv$V1)




# Data base for in class cross validation
names(data_hsv) <- paste0("base",seq(1:ncol(data_hsv)))
names(data_hsv)

#   load("/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/cycle3cvd-team-6/data/baseline feature.RData")
new_features <- read.csv("/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/cycle3cvd-team-6/data/new_features.csv", header=F)
names(new_features) <- paste0("new",seq(1:ncol(new_features)))
names(new_features)

feature_eval <- cbind(data_hsv,new_features)
save(feature_eval,file = "output/feature_eval.RData")
