import cv2
import joblib
import os
import csv
import numpy
import sklearn
from sklearn import svm
import time
from random import randint

os.getcwd()
os.chdir('/Users/JPC/Documents/Python')
# Indexes from R with corrupt files 
corrupt=numpy.array([140, 152, 2237, 2246, 2247, 2253, 2265, 2274, 2283, 2293, 2299, 6903, 6909]+[4,6,8])
corrupt=numpy.array(corrupt)-numpy.array([1]*len(corrupt))

# R names 
with open("names.txt","r") as file2:
    names= file2.read().split("\n")

names=names[0:len(names)-1]

with open("class.txt","r") as file:
    image_classes= file.read().split("\n")

image_classes=image_classes[0:len(image_classes)-1] 

index=set(range(len(image_classes)))
index=index.difference(corrupt)

image_classes=[image_classes[i] for i in index]

folderPath='/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/images'
image_names = os.listdir(folderPath)
image_names = image_names[2:len(image_names)+1]

names==image_names

image_names=[image_names[i] for i in index]

#total=500

# image_classes_train=image_classes[0:total]
image_classes_train=image_classes
# image_classes_test=image_classes[total+2000:total+2000+1000]
# training_names=image_names
training_names=image_names
#testing_names=image_names[total+2000:total+2000+1000]

image_paths = [os.path.join(folderPath, f) for f in training_names]
# testing_paths=[os.path.join(folderPath, f) for f in testing_names]

# feature_det = cv2.FeatureDetector_create("SIFT")
feature_det = cv2.xfeatures2d.SIFT_create()


def preProcessImages(image_paths):
    descriptors= []
    for image_path in image_paths:
        im = cv2.imread(image_path)
        kpts = feature_det.detect(im)
        # kpts, des = descr_ext.compute(im, kpts)
        kpts, des = feature_det.compute(im, kpts)
        descriptors.append(des)
    return descriptors

start = time.time()
descriptors=preProcessImages(image_paths)
end = time.time()
print("minutes spent in Descriptors")
print((end - start)/60)


descriptors_none=[]
for i, j in enumerate(descriptors):
    if j == None:
        descriptors_none.append(i)

descriptors=[i for i in descriptors if i!= None]
image_classes_train=[image_classes_train[i] for i in range(len(image_classes_train)) if i not in descriptors_none]
image_paths=[image_paths[i] for i in range(len(image_paths)) if i not in descriptors_none]

def getImagedata(feature_det,bow_extract,path):
    im = cv2.imread(path)
    featureset = bow_extract.compute(im, feature_det.detect(im))
    return featureset

# def train(descriptors,image_classes_train,image_paths):  
flann_params = dict(algorithm = 1, trees = 5)     
matcher = cv2.FlannBasedMatcher(flann_params, {})
# bow_extract  =cv2.BOWImgDescriptorExtractor(descr_ext,matcher)
bow_extract  =cv2.BOWImgDescriptorExtractor(feature_det,matcher)
bow_train = cv2.BOWKMeansTrainer(500)
for des in descriptors:
    bow_train.add(des)

start = time.time()
voc = bow_train.cluster()
bow_extract.setVocabulary( voc )
end = time.time()
print("minutes spent in creating Vocabulary")
print((end - start)/60)


traindata = []  
start = time.time()
for imagepath in image_paths:
    featureset = getImagedata(feature_det,bow_extract,imagepath)
    traindata.extend(featureset)

end = time.time()
print("minutes spent in Extracting vocabulary")
print((end - start)/60)

clf=sklearn.svm.classes.LinearSVC()
# clf = LinearSVC()
clf.fit(traindata, numpy.array(image_classes_train))
joblib.dump((voc,clf), "imagereco.pkl", compress=3)

# model=train(descriptors,image_classes_train,image_paths)
voc, clf = joblib.load("imagereco.pkl")


X=numpy.matrix(traindata)
numpy.savetxt('X2.csv', X,delimiter=',')

my_file = open("label_2_2.txt", "w")
for item in image_classes_train:
    my_file.write("%s\n" % item)

my_file.close()

my_file = open("animal_names_2.txt", "w")
for item in training_names:
    my_file.write("%s\n" % item)

my_file.close()



# Accuracy Training data
prediction = clf.predict(traindata)
p=numpy.array(prediction)
c=numpy.array(image_classes_train)
print("Accuracy with training")
numpy.sum(p==c)/(len(prediction)*1.000)




# Accuracy Test data
prediction_test=[]
for imagepath in testing_paths:
    featureset = getImagedata(feature_det,bow_extract,imagepath)
    prediction_temp = clf.predict(featureset)
    if list(prediction_temp) ==['1']:
        prediction_test.append('1')
    else:
        prediction_test.append('0')


p=numpy.array(prediction_test)
c=numpy.array(image_classes_test)
print("Accuracy with training")
numpy.sum(p==c)/(len(prediction_test)*1.000)






