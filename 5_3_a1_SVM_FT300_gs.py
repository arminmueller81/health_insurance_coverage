# Technical Paper:
# Text Mining and Document Classification Workflows for Chinese Administrative Documents
# File 5.3.a1 - Support Vector Machine Grid Search

print("4. Support Vector Machine Grid Search with fastText-encoded data")

print("commencing SVM workflow ...")

# set the penalty C for feature selection
penalty = 1
# <=1; lower C --> fewer features

# 4.1 load packages and data
print("loading packages and data ...")
import os
import numpy as np
import pandas as pd
import joblib
import random
from sklearn.utils import resample
from sklearn.svm import LinearSVC, SVC
from sklearn.feature_selection import SelectFromModel
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.model_selection import GridSearchCV, StratifiedKFold
from sklearn.metrics import confusion_matrix

# Set seeds for reproducability
np.random.seed(421)
random.seed(421)


# Work directory: decides the dataset to be used
os.chdir("workin_directory") # Windows

print("loading the data")
# Load Y
y_train = pd.read_csv('./dta_health/y_broad_train.csv')['y_broad']
y_test = pd.read_csv('./dta_health/y_broad_test.csv')['y_broad']

# Load Fasttext data
x_train = pd.read_csv('./dta_health/train_embeddedFT_300.csv', header=None).to_numpy()
x_test = pd.read_csv('./dta_health/test_embeddedFT_300.csv', header=None).to_numpy()


# 4.2 Feature selection
print("commencing feature selection ...")
print("shape of the matrix before applying the embedded feature selection:", x_train.shape)

lsvc = LinearSVC(C=penalty,
                 penalty="l1", 
                 random_state=421,
                 max_iter = 10000, # max number of iterations
                 dual=False)

model = SelectFromModel(lsvc).fit(x_train, y_train) 

X_new = model.transform(x_train)
print("shape of the matrix after applying the embedded feature selection:", X_new.shape)

# Transform the test data
x_test_transformed = model.transform(x_test)


# 4.3 upsampling
print("commencing upsampling ...")

# Select the minority class samples
minority_class_samples = X_new[y_train == 1]

# Extract the corresponding labels for the minority class samples.
minority_class_labels = y_train[y_train == 1]

# Upsample the minority class to match the majority class
X_upsampled, y_upsampled = resample(minority_class_samples, 
                                    minority_class_labels, 
                                    replace=True, 
                                    n_samples=X_new[y_train == 0].shape[0], 
                                    random_state=421) 

print('Number of class 1 examples after:', X_upsampled.shape[0])

# Put dataframes together again
X_bal = np.vstack((X_new[y_train == 0], X_upsampled))
y_bal = np.hstack((y_train[y_train == 0], y_upsampled))


# 4.4 Dimensionality Reduction
print("commencing dimensionality reduction ...")

# Scale the data
scaler = StandardScaler(with_mean=False)  # with_mean=False for sparse matrices
X_bal_scaled = scaler.fit_transform(X_bal)
x_test_scaled = scaler.fit_transform(x_test_transformed)

# Principal Component Analysis
pca = PCA(n_components=0.95)  # Retain 95% variance
X_bal_pca = pca.fit_transform(X_bal_scaled)
x_test_pca = pca.transform(x_test_scaled)

print("shape of the training matrix after PCA:", X_bal_pca.shape)
print("shape of the test matrix after PCA:", x_test_pca.shape)



# 4.4 Model grid search

print("defining training grid ...")
# linear kernel
param_grid_lin = {
    'kernel': ['linear'], 
    'C': np.arange(0.1, 15, 0.5) 
}

# polinomial kernel
param_grid_poly = {
    'kernel': ['poly'], 
    'C': np.arange(0.1, 15, 0.5), 
    'degree': list(range(2, 3, 1)),
    'gamma': list(range(1, 100, 5)), 
}

# radial kernel
param_grid_rbf = {
    'kernel': ['rbf'], 
    'C': np.arange(0.1, 15, 0.5), 
    'gamma': list(range(1, 100, 5)), 
}


# set up cross-validation, classifier and grid search
# use stratified_cv with imbalanced, rather than upsampled data
#stratified_cv = StratifiedKFold(n_splits = 10, shuffle = True, random_state=42)
svm_classifier = SVC(random_state=421)

gs = GridSearchCV(estimator=svm_classifier,
                  param_grid=param_grid_lin, # select the grid for the kernel of choice
                  # optimize on multiple criteria, specify refit for best one.
                  scoring=['accuracy', 'recall'], 
                  cv = None, # default: None = 5 fold; stratified_cv
                  refit='recall',
                  verbose=2, # progress report
                  n_jobs=-1) # 1: only 1 CPU; -1: all CPUs

print("commencing training ...")
gs = gs.fit(X_bal_pca, y_bal)

print("Training completed - best model configuration: ")
print("Parameters: ", gs.best_params_)
print("Training data accuracy: ", gs.best_score_)

# Estimation
clf = gs.best_estimator_
print('Test data accuracy: %.3f' % clf.score(x_test_pca, y_test))

# Confusion matrix
cm = confusion_matrix(y_true=y_test, y_pred=clf.predict(x_test_pca))
print(cm)

# Extracting values from confusion matrix
true_positives = cm[1, 1] 
false_negatives = cm[1, 0]
false_positives = cm[0, 1]

# Calculating sensitivity
sensitivity = true_positives / (true_positives + false_negatives)
precision = true_positives / (true_positives + false_positives)

print('Accuracy (test data): %.3f' % clf.score(x_test_pca, y_test))
print('Sensitivity (test data): %.3f' % sensitivity)
print('Precision (test data): %.3f' % precision)