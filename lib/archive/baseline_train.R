# Load data using the following 
# load("train_data.RDS")
# load("test_data.RDS")

train <- function(train,label){
  library("e1071")
  lin_svm<-svm(train,label, kernel="linear",scale=F)
  return(lin_svm)
}