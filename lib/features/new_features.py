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

folderPath='/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/images'
image_names = os.listdir(folderPath)
image_names = image_names[2:len(image_names)+1]

# corrupt=numpy.array([140, 152, 2237, 2246, 2247, 2253, 2265, 2274, 2283, 2293, 2299, 6903, 6909]+[4,6,8])
# corrupt=numpy.array(corrupt)-numpy.array([1]*len(corrupt))
# index=set(range(len(image_names)))
# index=index.difference(corrupt)
# image_names=[image_names[i] for i in index]

image_paths = [os.path.join(folderPath, f) for f in image_names]
feature_det = cv2.xfeatures2d.SIFT_create()

def getImagedata(feature_det,bow_extract,path):
    im = cv2.imread(path)
    featureset = bow_extract.compute(im, feature_det.detect(im))
    return featureset

# def train(descriptors,image_classes_train,image_paths):  
flann_params = dict(algorithm = 1, trees = 5)     
matcher = cv2.FlannBasedMatcher(flann_params, {})
# bow_extract  =cv2.BOWImgDescriptorExtractor(descr_ext,matcher)
bow_extract  =cv2.BOWImgDescriptorExtractor(feature_det,matcher)
voc = joblib.load("/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/cycle3cvd-team-6/data/imagereco.pkl")
bow_extract.setVocabulary( voc )

traindata = []  
start = time.time()
for imagepath in image_paths:
    featureset = getImagedata(feature_det,bow_extract,imagepath)
    traindata.extend(featureset)

end = time.time()
print("minutes spent in Extracting vocabulary")
print((end - start)/60)

# model=train(descriptors,image_classes_train,image_paths)

X=numpy.matrix(traindata)
numpy.savetxt('/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/cycle3cvd-team-6/data/new_features.csv', X,delimiter=',')

my_file = open("label_2_2.txt", "w")
for item in image_classes_train:
    my_file.write("%s\n" % item)

my_file.close()

my_file = open("animal_names_2.txt", "w")
for item in training_names:
    my_file.write("%s\n" % item)

my_file.close()

