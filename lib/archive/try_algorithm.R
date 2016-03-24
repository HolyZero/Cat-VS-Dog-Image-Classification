library(e1071)
library(caret)
library(adabag)
library(randomForest)
library(cvTools)
library(dismo)

# Read in feature table and label, and format it into one table
setwd("~/Documents/cycle3cvd-team-6/data")
feature <- read.csv("new_features.csv", header = FALSE)
label_file <- read.csv("archive/labels.csv")
feature$label <- as.factor(label_file[,3])
summary(feature$label)

# Create training and testing data set
inTrain <- createDataPartition(feature$label, p = 0.75, list = FALSE)
training <- feature[inTrain,]
testing <- feature[-inTrain,]

# Naiive Bayes model, and calculate the test rate.
system.time(modnb <- naiveBayes(label ~ ., data = training))
pred <- predict(modnb, testing)
mean(pred == testing$label)

# Gradient boosting model, calculate the test rate.
modgbm <- train(label~., method="gbm", data = training, verbose=FALSE)
pred2 <- predict(modgbm, testing)
mean(pred2 == testing$label)

# Random forest model, calculate the test rate.
modrf <- train(label~., data=training, method="rf", prox=TRUE)
getTree(modrf$finalModel, k=2)  # Show one tree in the random forest
pred3 <- predict(modrf, testing)
mean(pred3 == testing$label)

# Adaboost model, model also includes weights for each feature
system.time(modada <- boosting(label~., data = training, boos = TRUE, 
                               mfinal = 100, coeflearn = 'Breiman'))
pred5 <- predict(modada, testing)
mean(pred5 == testing$label)

# SVM with four kernels, return rate for each of them
system.time(modsvm <- svm(label~., data = training, type = "C", kernel = "linear"))
modsvm <- svm(label~., data = training, type = "C", kernel = "polynomial")
# 5.25 seconds for training svm
modsvm <- svm(label~., data = training, type = "C", kernel = "radial")
modsvm <- svm(label~., data = training, type = "C", kernel = "sigmoid")
pred6 <- predict(modsvm, testing)
mean(pred6 == testing$label)

# Majority vote function, seems doesn't actually increase our model
# Create a function which can output the mode of a vector, and then use 
# this function to create majority vote function.
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
predMJ <- as.factor(mj(result))
mean(predMJ == testing$label)


# Cross validation to test stability of each algorithm
# If want to test on different algorithms, we should change
# the algorithm inside the cv function.
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
  # return mean train error, mean test error, and test error standard deviation
  return(c(mean(train.error),mean(cv.error),sd(cv.error)))
}
# Call the cross validate with 5 fold.
cv.function(feature, 5)

############## PCA
# Use PCA to reduce the dimension of feature space,
# however, performance of each model doesn't increase a lot.
pc <- prcomp(feature[,-501])
summary(pc)
pcfeature <- as.data.frame(pc$x[,1:100])
pcfeature$label = feature$label
PCtraining <- pcfeature[inTrain,]
PCtesting <- pcfeature[-inTrain,]
# Check performance of PCA with our best performance model.
modsvm <- svm(label~., data = PCtraining, type = "C", kernel = "radial")
pred <- predict(modsvm, PCtesting)
mean(pred == PCtesting$label)