# Technical Paper:
# Text Mining and Document Classification Workflows for Chinese Administrative Documents
# File 5.3.b - Prediction with Random Forest
# The model was previously trained by hand and can either be reproduced or loaded here.


print("loading packages and data")
# 1. Load packages & data
import pandas as pd 
import numpy as np
import joblib
import random
import os
import pickle # load model
from sklearn.utils import resample
from sklearn import metrics
from sklearn.metrics import accuracy_score, recall_score
from sklearn.metrics import confusion_matrix
from sklearn.ensemble import RandomForestClassifier

# set seed for reproducibility
random.seed(421)
np.random.seed(421)

print("Step 2: loading data")
os.chdir("/home/amueller/dta_health")

# Y
y_train = pd.read_csv('./y_broad_train.csv')['y_broad']
y_test = pd.read_csv('./y_broad_test.csv')['y_broad']

# X (multihot encoded)
vocabulary = pd.read_csv('vocabulary.csv').iloc[:,1].tolist()
x_train = pd.DataFrame(joblib.load('./X_multihot_train_sparse.pkl').astype(np.uint8).toarray(), columns=vocabulary)
x_train.shape
x_test = pd.DataFrame(joblib.load('./X_multihot_test_sparse.pkl').astype(np.uint8).toarray(), columns=vocabulary)
x_test.shape
x_unlabelled = pd.DataFrame(joblib.load('X_unlabelled_multihot_sparse.pkl').astype(np.uint8).toarray(), columns=vocabulary)
x_unlabelled.shape



print("Step 3: reproduce/load the model")

print("... upsampling training data ...")
# Select the minority class samples
minority_class_samples = x_train[y_train == 1]

# Extract the corresponding labels for the minority class samples.
minority_class_labels = y_train[y_train == 1]

# Upsample the minority class to match the majority class
X_upsampled, y_upsampled = resample(minority_class_samples, # upsample the minority class samples (minority_class_samples) ...
                                    minority_class_labels, # ... and labels (minority_class_labels) to match the number of samples in the majority class
                                    replace=True, # sampling with replacement 
                                    n_samples=x_train[y_train == 0].shape[0], # the desired number of samples, set to number of samples in the majority class
                                    random_state=123) # seed for reproducibility

## Put dataframes together again
X_bal = pd.DataFrame(np.vstack((x_train[y_train == 0], X_upsampled)), columns=vocabulary)
y_bal = np.hstack((y_train[y_train == 0], y_upsampled))

print("... reproducing the model ....")
RanFo_Classifier = RandomForestClassifier(n_estimators=530, # number of trees
                                  max_depth=33, # maximum depth of the tree
                                  min_samples_leaf=2, # minimum samples in leaf node 
                                  random_state=1)

clf = RanFo_Classifier.fit(X_bal, y_bal)

#print("... loading model ...")
#with open("Ranfo_MH_20250211_A93_S85", 'rb') as file: clf = pickle.load(file)
#print(clf)



print("Step 4: Test the model")
print('Accuracy: %.3f' % clf.score(x_test, y_test))

# Classification report
y_pred_test =clf.predict(x_test)
print(metrics.classification_report(y_true=y_test, y_pred=y_pred_test))

# Confusion Matrix
conf_matrix = confusion_matrix(y_true=y_test, y_pred=y_pred_test)
print("\nConfusion Matrix:")
print(conf_matrix)

print("Step 5: Predict on unlabelled data")
data_predictions = pd.read_csv('data_predictions_FFNN.csv')
data_predictions['ranfo_predictions'] = clf.predict(x_unlabelled)

# save
data_predictions.to_csv('data_predictions_FFNN_RANFO.csv', index=False)
