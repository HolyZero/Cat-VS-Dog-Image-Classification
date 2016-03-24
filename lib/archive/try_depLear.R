##################### H2O
# Use H2O engine to do large computations for our problem.
# In this file, I use h2o package build gbm, random forest,
# and feed forward nerual network models.

library(h2o)
library(caret)

# Same process as the other file to generate feature dataset
setwd("~/Documents/cycle3cvd-team-6/data")
feature <- read.csv("new_features.csv", header = FALSE)
label_file <- read.csv("archive/labels.csv")
feature$label <- as.factor(label_file[,3])
summary(feature$label)

# Create training and testing data set
inTrain <- createDataPartition(feature$label, p = 0.65, list = FALSE)
training <- feature[inTrain,]
testing <- feature[-inTrain,]

# Initialize a h2o engine for later calculation.
localH2O <- h2o.init(ip = "localhost", port = 54321, startH2O = TRUE,
                     max_mem_size = "5g")
h2o.clusterInfo()

# Write corresponding R dataset to CSV for reading into h2o engine later
write.csv(training, "X3.csv")
write.csv(testing, "X4.csv")
write.csv(feature, "XX.csv")
# Read in corresponding feature, training, and testing dataset into h2o engine
feature_h2o = h2o.importFile(path = "XX.csv", destination_frame = "lolf")
feature_h2o[,"label"] <-  as.factor(feature_h2o[,"label"])
pathToFolder = "X3.csv"
train_h2o = h2o.importFile(path = pathToFolder, destination_frame = "lol")
train_h2o[,"label"] <-  as.factor(train_h2o[,"label"])
pathToFolder2 = "X4.csv"
test_h2o = h2o.importFile(path = pathToFolder2, destination_frame = "lol2")

# Feed forward neural network model.
model <- 
  h2o.deeplearning(x = 1:500,  # column numbers for predictors
                   y = "label",   # column number for label
                   training_frame = feature_h2o, # data in H2O format
                   overwrite_with_best_model = TRUE,
                   activation = "RectifierWithDropout", # or 'Tanh'
                   input_dropout_ratio = 0.2, # % of inputs dropout
                   hidden_dropout_ratios = c(0.5,0.5,0.5), # % for nodes dropout
                   hidden = c(50,50,50), # three layers of 50 nodes
                   epochs = 100 # max. no. of epochs
                   ) 
# GBM in h2o engine
model <- h2o.gbm(x = 1:500, y = "label", training_frame = feature_h2o)
# Random forest in h2o engine
model <- h2o.randomForest(x = 1:500, y = "label", training_frame = train_h2o, ntrees = 800)

# Train model and predict new features in H2O engine
h2o_yhat_test <- h2o.predict(model, test_h2o)
pred_train <- as.data.frame(train_check)
mean(pred_train$predict == testing$label)