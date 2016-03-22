## Start a local cluster with 1GB RAM (default)
library(h2o)
localH2O <- h2o.init(ip = "localhost", port = 54321, startH2O = TRUE)
h2o.clusterInfo()


## Import MNIST CSV as H2O
dat <- train  # remove the ID column
train_h2 = as.h2o(dat, destination_frame = "lol")
write.csv(training, "X3.csv")
write.csv(testing, "X4.csv")

prosPath <- system.file("extdata", "prostate.csv", package="h2o")
prostate.hex <- h2o.uploadFile(path = prosPath)
prostate.hex[,2] <- as.factor (prostate.hex[,2])

pathToFolder = "X3.csv"
train_h2o = h2o.importFile(path = pathToFolder, destination_frame = "lol")
summary(train_h2o)
train_h2o[,"label"] <-  as.factor(train_h2o[,"label"])
train_h2o
pathToFolder = "X4.csv"
test_h2o = h2o.importFile(path = pathToFolder, destination_frame = "lol2")
summary(train_h2o)


model <- 
  h2o.deeplearning(x = 1:20,  # column numbers for predictors
                   y = "label",   # column number for label
                   training_frame = train_h2o, # data in H2O format
                   overwrite_with_best_model = TRUE,
                   activation = "TanhWithDropout", # or 'Tanh'
                   input_dropout_ratio = 0.2, # % of inputs dropout
                   hidden_dropout_ratios = c(0.5,0.5,0.5), # % for nodes dropout
                   #balance_classes = TRUE, 
                   hidden = c(50,50,50), # three layers of 50 nodes
                   epochs = 100) # max. no. of epochs

h2o_yhat_test <- h2o.predict(model, test_h2o)
summary(h2o_yhat_test)
predinf <- as.data.frame(h2o_yhat_test)
head(predinf)
length(which(predinf$predict == testing$label))/499
