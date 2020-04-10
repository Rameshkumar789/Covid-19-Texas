# Packages
from scipy.io import loadmat
import numpy as np
import math
import LBP_Algorithm as lbp


#Loading the Data
data = loadmat('AR_database.mat')
Train_Data = data['Tr_dataMatrix']
Train_Labels = data['Tr_sampleLabels']
Test_Data = data['Tt_dataMatrix']
Test_Labels = data['Tt_sampleLabels']

# Train Data
# Reshape the train data (120,165)
Train_da=[]
Train=[]
Train_Data=Train_Data.transpose()
for i in range(len(Train_Data)):
    Train_da.append(Train_Data[i].reshape(120,165))
Data_train= np.array(Train_da)

# Resize 64*64
for i in range(len(Data_train)):
    t=Data_train[i].copy()
    t.resize(64,64)
    Train.append(t)
Data_train= np.array(Train)


#Reshape the Train_Labels
Train_Labels=Train_Labels.transpose()

# Test Data
# Reshape the Test data
Test_da=[]
Test=[]
Test_Data=Test_Data.transpose()
for i in range(len(Test_Data)):
    Test_da.append(Test_Data[i].reshape(120,165))
Data_test= np.array(Test_da)

# Resize 64*64
for i in range(len(Data_test)):
    t=Data_test[i].copy()
    t.resize(64,64)
    Test.append(t)
Data_test= np.array(Test)

# Reshape the Test_Labels
Test_Labels=Test_Labels.transpose()


#LBP_algorithm
Data_train=lbp.LBP_algorithm(Data_train)
Data_test=lbp.LBP_algorithm(Data_test)


#Flatten the Test and Train labels
Test_Labels=Test_Labels.flatten()
Train_Labels=Train_Labels.flatten()


# Converting 3D to 2D array
Data_train=Data_train.reshape((Data_train.shape[0], -1))
Data_test=Data_test.reshape((Data_test.shape[0],-1))


#SVM CLASSIFIER
from sklearn import svm
from sklearn import metrics

#linear
clf = svm.SVC(kernel='linear')
clf.fit(Data_train, Train_Labels)
Pred = clf.predict(Data_test)
print("Linear Kernal Accuracy:",metrics.accuracy_score(Test_Labels, Pred))

# Gaussian Kernel
clf = svm.SVC(kernel='rbf')
clf.fit(Data_train, Train_Labels)
Pred = clf.predict(Data_test)
print("Gaussian Kernal Accuracy:",metrics.accuracy_score(Test_Labels, Pred))

# Polynomial Kernel
clf = svm.SVC(kernel='poly', degree=5)
clf.fit(Data_train, Train_Labels)
Pred = clf.predict(Data_test)
print("Polynomial Kernal Accuracy:",metrics.accuracy_score(Test_Labels, Pred))


#KNN
from sklearn import neighbors
k1 = neighbors.KNeighborsClassifier(n_neighbors=3, weights='distance')
k1.fit(Data_train, Train_Labels)
k1_pred = k1.predict(Data_test)
print("KNN Accuracy:",metrics.accuracy_score(Test_Labels, k1_pred))
