library(e1071)
library(caret)
library(adabag)
library(randomForest)

setwd("~/Documents/cycle3cvd-team-6/data")
feature <- read.csv("500*2000/X500_2000.csv", header = FALSE)
label <- read.table("500*2000/label500_2000.txt")

feature <- read.csv("X2.csv", header = FALSE)
label <- read.table("label_2_2.txt")

feature$label <- as.factor(as.matrix(label))
summary(feature$label)
#zero <- subset(feature, label==0)
#one <- subset(feature, label==1)
#zero <- zero[1:202,]
#feature <- rbind(one, zero)

# Create training and testing data set
inTrain <- createDataPartition(feature$label, p = 0.75, list = FALSE)
training <- feature[inTrain,]
testing <- feature[-inTrain,]

system.time(modnb <- naiveBayes(label ~ ., data = training))
pred <- predict(modnb, testing[,-21])
length(which(pred == testing$label))/499

system.time(modgbm <- train(label~., method="gbm", data = training, verbose=FALSE))
pred2 <- predict(modgbm, testing)
length(which(pred2 == testing$label))/499

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
                               mfinal = 200, coeflearn = 'Breiman'))
pred5 <- predict(modada, testing)
length(which(pred5$class == testing$label))/499

system.time(modsvm <- svm(label~., data = training, type = "C", kernel = "linear"))
modsvm <- svm(label~., data = training, type = "C", kernel = "polynomial")
# 5.25 seconds for training svm
system.time(modsvm <- svm(label~., data = training, type = "C", kernel = "radial"))
modsvm <- svm(label~., data = training, type = "C", kernel = "sigmoid")

pred6 <- predict(modsvm, testing)
length(which(pred6 == testing$label))/499
