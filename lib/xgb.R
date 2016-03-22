label2=read.table("C:/Users/Administrator/Documents/GitHub/cycle3cvd-team-6/data/label_2_2.txt")
x=read.csv("C:/Users/Administrator/Documents/GitHub/cycle3cvd-team-6/data/X2.csv",head=F)
label = read.csv("C:/Users/Administrator/Documents/GitHub/cycle3cvd-team-6/data/labels.csv")
an_names =  read.table("C:/Users/Administrator/Documents/GitHub/cycle3cvd-team-6/data/animal_names.txt")
load("C:/Users/Administrator/Documents/GitHub/cycle3cvd-team-6/data/data_hsv.RData")

#xgboost method in 2000 pictures with 20 features
install.packages("xgboost")
library(xgboost)
x = as.matrix(x)
train = cbind(label,x)
train2 = cbind(label2,x)
bst <- xgboost(data = x, label=train2[,1], nrounds=20,objective = "binary:logistic")
pred <- predict(bst, x)
xgb.cv(data = x, label = train2[,1], nround = 20, objective = "binary:logistic", nfold = 10)

#svm method in 2000 pictures with 20 features
install.packages("e1071")
library(e1071)
install.packages("caret")
library(caret)
inTrain<-createDataPartition(train2$V1,p=0.80,list=FALSE)
train<-train2[inTrain,]
test<-train2[-inTrain,]
save(train,file="train_data.RDS")
save(test,file="test_data.RDS")

svm=svm(train[,-1],as.factor(train[,1]),cross=10)
aaa<-predict(svm,test[,-1])
sum(aaa!=as.factor(test[,1]))/length(test[,1])

#adaboost method in 2000 pictures with 20 features
library(adabag)
names(train)=c("V1","V2","V3","V4","V5","V6","V7","V8","V9","V10","V11","V12","V13","V14","V15","V16","V17","V18","V19","V20","V21")
adaboost=boosting(V1~.,data=train,boos=TRUE, mfinal=5,control = (minsplit = 0))

                  