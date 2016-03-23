library(e1071)
library(caret)
library(adabag)
library(randomForest)
library(cvTools)
library(dismo)
setwd("~/Documents/cycle3cvd-team-6/data")
#feature20 <- read.csv("new features model selection.csv", header = FALSE)
rm(feature20)
feature <- read.csv("new_features.csv", header = FALSE)
label_file <- read.csv("archive/labels.csv")

feature$label <- as.factor(label_file[,3])
summary(feature$label)

# Create training and testing data set
inTrain <- createDataPartition(feature$label, p = 0.75, list = FALSE)
training <- feature[inTrain,]
testing <- feature[-inTrain,]

system.time(modnb <- naiveBayes(label ~ ., data = training))
pred <- predict(modnb, testing[,-21])
length(which(pred == testing$label))/1844

modgbm <- train(label~., method="gbm", data = training, verbose=FALSE)
pred2 <- predict(modgbm, testing)
length(which(pred2 == testing$label))/1844

modrf <- train(label~., data=training, method="rf", prox=TRUE)
getTree(modrf$finalModel, k=2)  # second tree
pred3 <- predict(modrf, testing)
length(which(pred3 == testing$label))/499

Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
mj <- function(result) {
  x <- c(1:nrow(result))
  for(i in 1:nrow(result)) {
    x[i] = Mode(result[i,])
  }
  return(x)
}
result <- cbind(pred, pred2, pred3)
pred4 <- mj(result)-1
length(which(pred4 == testing$label))/499

system.time(modada <- boosting(label~., data = training, boos = TRUE, 
                               mfinal = 10, coeflearn = 'Breiman'))
pred5 <- predict(modada, testing)
length(which(pred5$class == testing$label))/499

system.time(modsvm <- svm(label~., data = training, type = "C", kernel = "linear"))
modsvm <- svm(label~., data = training, type = "C", kernel = "polynomial")
# 5.25 seconds for training svm
system.time()
modsvm <- svm(label~., data = feature, type = "C", kernel = "radial")
predall <- predict(modsvm, feature)
length(which(predall == feature$label))/7377

modsvm <- svm(label~., data = training, type = "C", kernel = "sigmoid")

pred6 <- predict(modsvm, testing)
length(which(pred6 == testing$label))/1844
mean(pred6 != testing$label)

fold <- cvFolds(7377)$subsets
fold <- kfold(feature, k = 5, by = feature$label)

cv.function <- function(X, K){
  
  fold <- kfold(X, k = K, by = X$label)
  cv.error <- rep(NA, K)
  train.error <- rep(NA, K)
  
  for (i in 1:K){
    train.data <- X[which(fold != i),]
    test.data <- X[which(fold==i),]
    #mod <- naiveBayes(label ~ ., data = X)
    mod <- svm(label~., data = train.data, type = "C", kernel = "radial")
    #mod <- svm(label~., data = X, type = "C", kernel = "linear")
    pred <- predict(mod, test.data)
    predtrain <- predict(mod, train.data)
    cv.error[i] <- mean(pred != test.data$label)  
    train.error[i] <- mean(predtrain != train.data$label)
  }			
  return(c(mean(train.error),mean(cv.error),sd(cv.error)))
}

cv.function(feature, 5)

## PC!!!!!!
pc <- prcomp(feature[,-501])
summary(pc)
pcfeature <- as.data.frame(pc$x[,1:100])
pcfeature$label = feature$label
PCtraining <- pcfeature[inTrain,]
PCtesting <- pcfeature[-inTrain,]

modsvm <- svm(label~., data = PCtraining, type = "C", kernel = "radial")
pred <- predict(modsvm, PCtesting)
length(which(pred == PCtesting$label))/1844
