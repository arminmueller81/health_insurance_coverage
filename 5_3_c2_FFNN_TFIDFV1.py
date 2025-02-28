# Technical Paper:
# Text Mining and Document Classification Workflows for Chinese Administrative Documents
# File 5_3_c1 - Feed-Forward Neural Network (prediction)

print("Feed-Forward Neural Network with TF-IDF data")


print("Step 1: loading packages")
import pandas as pd # data manipulation
import numpy as np
import random
import os
import joblib
from sklearn.utils import resample
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix
from sklearn.svm import LinearSVC
from sklearn.feature_selection import SelectFromModel
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras import models
from tensorflow.keras.callbacks import EarlyStopping
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.metrics import Recall
from sklearn.metrics import confusion_matrix

print("check GPU support")
print("Num GPUs Available: ", len(tf.config.experimental.list_physical_devices('GPU')))


print("set a seed")
random.seed(421)           # Python random module
np.random.seed(421)        # NumPy random generator
tf.random.set_seed(421)    # TensorFlow/Keras random generator

print("Step 2: loading data")
os.chdir("/home/amueller/dta_health") 
# Y
y_train = pd.read_csv('./y_broad_train.csv')['y_broad']
y_test = pd.read_csv('./y_broad_test.csv')['y_broad']
#train_ybroad.value_counts()
y_train.value_counts()

# X TF-IDF
tfidf_feature_names = pd.read_csv('tfidf_feature_names.csv').iloc[:,1].tolist()
print("taining data")
X_tfidf_train = pd.DataFrame(joblib.load('./tfidf_matrix_train.pkl').toarray(), columns=tfidf_feature_names)
X_tfidf_train.shape
print("test data")
X_tfidf_test = pd.DataFrame(joblib.load('./tfidf_matrix_test.pkl').toarray(), columns=tfidf_feature_names)
X_tfidf_test.shape
print("unlabelled data")
X_tfidf_unlabelled = pd.DataFrame(joblib.load('tfidf_matrix_unlabelled_broadvoc.pkl').toarray(), columns=tfidf_feature_names)
X_tfidf_unlabelled.shape

print("Step 3: Feature Selection")
# SVM model with penalty
lsvc = LinearSVC(C=2, # lower C --> fewer features
                 penalty="l1", 
                 dual=False,
                 random_state=421,
                 max_iter = 5000)
model = SelectFromModel(lsvc).fit(X_tfidf_train, y_train) 

# get all feature names
feature_names = X_tfidf_train.columns if hasattr(X_tfidf_train, "columns") else np.arange(X_tfidf_train.shape[1])
# Get the mask of selected features
selected_features_mask = model.get_support()
# Extract names of the selected features
selected_feature_names = feature_names[selected_features_mask]

# transform the training data
X_tfidf_train_transformed = model.transform(X_tfidf_train)
X_tfidf_train_transformed = pd.DataFrame(X_tfidf_train_transformed, columns=selected_feature_names)
print("shape of the matrix after applying the embedded feature selection:", X_tfidf_train_transformed.shape)

# Transform the test data
X_tfidf_test_transformed = model.transform(X_tfidf_test)
X_tfidf_test_transformed = pd.DataFrame(X_tfidf_test_transformed, columns=selected_feature_names)
print("shape of the matrix after applying the embedded feature selection:", X_tfidf_test_transformed.shape)

# transform the unlabelled data
X_tfidf_unlabelled_transformed = model.transform(X_tfidf_unlabelled)
X_tfidf_unlabelled_transformed = pd.DataFrame(X_tfidf_unlabelled_transformed, columns=selected_feature_names)
print("shape of the matrix after applying the embedded feature selection:", X_tfidf_unlabelled_transformed.shape)

print("Step 4: Validation sample and upsampling")

# load function and create stratified split
x_train2, x_val, y_train2, y_val = train_test_split(X_tfidf_train_transformed, y_train, 
                                                    test_size=0.3, stratify=y_train, random_state=42)

print("check validation sample")
x_val.shape
y_val.value_counts()

print("upsampling training data")
# Select the minority class samples
minority_class_samples = x_train2[y_train2 == 1]

# Extract the corresponding labels for the minority class samples.
minority_class_labels = y_train2[y_train2 == 1]


# Upsample the minority class to match the majority class
X_upsampled, y_upsampled = resample(minority_class_samples, # upsample the minority class samples 
                                    minority_class_labels, # upsample labels 
                                    replace=True, # add more to the original number of samples
                                    n_samples=x_train2[y_train2 == 0].shape[0], # desired number of samples
                                    random_state=421) # seed for reproducibility.

print('Number of class 1 examples after:', X_upsampled.shape[0])

print("create and check balanced data")
X_bal = pd.DataFrame(np.vstack((x_train2[y_train2 == 0], X_upsampled)), columns=selected_feature_names)
y_bal = np.hstack((y_train2[y_train2 == 0], y_upsampled))
X_bal.shape
y_bal.shape

print("Step 5: Dimensionality reduction")


# Scaling the data
scaler = StandardScaler(with_mean=False)  # with_mean=False for sparse matrices
X_bal_scaled = scaler.fit_transform(X_bal)
x_val_scaled = scaler.fit_transform(x_val)
x_test_scaled = scaler.fit_transform(X_tfidf_test_transformed)
x_unlabelled_scaled = scaler.fit_transform(X_tfidf_unlabelled_transformed)

# Principal Component Analysis
pca = PCA(n_components=0.95)  # Retain 95% variance
X_train_pca = pca.fit_transform(X_bal_scaled)
x_val_pca = pca.transform(x_val_scaled)
x_test_pca = pca.transform(x_test_scaled)
x_unlabelled_pca = pca.transform(x_unlabelled_scaled)


print("Step 6: Design and train a Fee-Forward Neural Network")

# define the architecture
model = models.Sequential()
model.add(layers.Dense(64, activation = 'relu', input_shape=(X_train_pca.shape[1],))) # number of features
model.add(Dropout(0.2))
model.add(layers.Dense(32, activation = 'relu'))
model.add(Dropout(0.8))
model.add(layers.Dense(16, activation = 'relu'))
model.add(Dropout(0.3))
model.add(layers.Dense(8, activation = 'relu'))
model.add(Dropout(0.5))
model.add(layers.Dense(1, activation= 'sigmoid'))
model.summary()


# compiling information
model.compile(optimizer='adam', # default
             loss='binary_crossentropy', # same as logit loss function
             metrics=['accuracy', Recall()]) # compile with accurary and recall

# Initialize the EarlyStopping callback
early_stopping = EarlyStopping(
    monitor='val_loss',
    patience=5,
    restore_best_weights=True, 
    verbose=1             
)

# training
history = model.fit(X_train_pca,
                   y_bal,
                   epochs=50,
                   batch_size=500,
                   callbacks=[early_stopping],
                   validation_data=(x_val_pca,y_val))


print("Step 7: Evaluation")
model.evaluate(x_test_pca, y_test)

# get the predictions
y_probs = model.predict(x_test_pca) # predictions come as probabilities
threshold = 0.5  # Adjust this threshold as needed
# Convert continuous predictions to binary labels
y_pred = (y_probs > threshold).astype(int)

# Calculate the confusion matrix
confusion = confusion_matrix(y_true=y_test, y_pred=y_pred)
print(confusion)

print("Step 8: Predictions un onlabelled data")

data_predictions = pd.read_csv('data_predictions.csv')
data_predictions['FFNN_predictions'] = model.predict(X_tfidf_unlabelled, batch_size=32)

data_predictions.to_csv('data_predictions_FFNN.csv', index=False)

data_predictions['FFNN_predictions'].value_counts()



