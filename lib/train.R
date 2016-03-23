# INSTALL ALL PACKAGES NEEDED, they should be compatible with R version 3.2.3 (2015-12-10) -- "Wooden Christmas-Tree"
# _________________________________________________________________________________________________
install.packages("e1071")


# LOAD ALL LIBRARIES NEEDED
# _________________________________________________________________________________________________
library("e1071")





# TRAIN FUNCTION
# _________________________________________________________________________________________________

# load("/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/cycle3cvd-team-6/data/feature_eval.RData")
# features=feature_eval
# labels <- read.table("/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/cycle3cvd-team-6/data/archive/label_2_2.txt")
train <- function(features,labels){
  names.base <- subset(names(features),substr(names(features),1,1)=="b")
  names.adv <- subset(names(features),substr(names(features),1,1)=="n")
  features.base <- features[,names.base]
  features.adv <- features[,names.adv]
  training.base <- data.frame(label=labels,features.base)
  training.adv <- data.frame(label=labels,features.adv)
  base.model <- svm(label~., data = training.base,  kernel="linear",scale=F)
  adv.model <- svm(label~., data = training.adv, type = "C", kernel = "radial")
  return(list(baseline=base.model,adv=adv.model))
}

#   model <- train(features,labels$V1)
