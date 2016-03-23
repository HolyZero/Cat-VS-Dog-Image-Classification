## Start a local cluster with 1GB RAM (default)
library(h2o)
library(caret)

setwd("~/Documents/cycle3cvd-team-6/data")
#feature20 <- read.csv("new features model selection.csv", header = FALSE)
rm(feature20)
feature <- read.csv("new_features.csv", header = FALSE)
label_file <- read.csv("archive/labels.csv")

feature$label <- as.factor(label_file[,3])
summary(feature$label)

# Create training and testing data set
inTrain <- createDataPartition(feature$label, p = 0.65, list = FALSE)
training <- feature[inTrain,]
testing <- feature[-inTrain,]

localH2O <- h2o.init(ip = "localhost", port = 54321, startH2O = TRUE,
                     max_mem_size = "5g")
h2o.clusterInfo()


## Import MNIST CSV as H2O
write.csv(training, "X3.csv")
write.csv(testing, "X4.csv")

pathToFolder = "X3.csv"
train_h2o = h2o.importFile(path = pathToFolder, destination_frame = "lol")
train_h2o[,"label"] <-  as.factor(train_h2o[,"label"])
pathToFolder2 = "X4.csv"
test_h2o = h2o.importFile(path = pathToFolder2, destination_frame = "lol2")
catch = as.data.frame(test_h2o)
rm(catch)

system.time(
model <- 
  h2o.deeplearning(x = 1:500,  # column numbers for predictors
                   y = "label",   # column number for label
                   training_frame = train_h2o, # data in H2O format
                   overwrite_with_best_model = TRUE,
                   activation = "RectifierWithDropout", # or 'Tanh'
                   input_dropout_ratio = 0.2, # % of inputs dropout
                   hidden_dropout_ratios = c(0.5,0.5,0.5), # % for nodes dropout
                   hidden = c(50,50,50), # three layers of 50 nodes
                   epochs = 100 # max. no. of epochs
                   ) 
)

model <- h2o.gbm(x = 1:500, y = "label", training_frame = train_h2o)
model <- h2o.randomForest(x = 1:500, y = "label", training_frame = train_h2o, ntrees = 800)


h2o_yhat_test <- h2o.predict(model, test_h2o)
train_check <- h2o.predict(model, train_h2o)
pred_train <- as.data.frame(train_check)
length(which(pred_train$predict == training$label))/5533
predinf <- as.data.frame(h2o_yhat_test)
length(which(predinf$predict == testing$label))/1844
