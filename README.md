# health_insurance_coverage
Document classification for Chinese health insurance coverage.

This repository accompanies the technical paper "Text Mining and Document Classification Workflows for Chinese Administrative Documents" published as part of project B05 ("Dynamics of Inclusion and Generosity in China's Welfare Regime") of the Collaborative Research Centre 1342 "Global Dynamics of Social Policy" of the German Research Foundation (Project number:  374666841 – SFB 1342“) at the University of Bremen in Germany (phase 2, 2022-2025).
The paper presents workflows for organizing and analyzing administrative documents in a relational database. The repository provides complementary code files, which are numbered in accordance with the sections of the paper they complement.
First, the R files accompanying section 3 prepare the data for import into the database; and they extract a set of training data for labelling and subsequent machine learning. For details, please refer to the technical paper.
Second, the Python files accompanying section 5 prepare the labelled data, train machine learning models, and predict on the unlabelled data.
File 5_2_a goes through data cleaning routines and splits the labelled data into training and test sets.
File 5_2_b1 vectorizes the data using multihot encoding and TF-IDF encoding.
File 5_2_b2 vectorizes the data with FastText embeddings; the code uses Python 3.8 and FastText.load_fasttext_format, which raises a deprecation warning.

File 5_3_a1 provides a grid search for an optimal Support Vector Machine in a .py file, and 5_3_a2 conducts model evaluation and prediction in a Jupyter notebook. Comments are concentrated in the latter file.

File 5_3_b uses a saved Random Forest model for predictions. The model was trained by hand with the following parameters: n_estimators=530, max_depth=33, min_samples_leaf=2, random_state=1.

File 5_3_c1 creates a Feed-Forward Neural Network using Tensorflow in a Jupyter notebook with comments. File 5_3_c2 conducts the predictions in a .py file.

File 5_3_d fine-tunes a Chinese MacBERT (large) model and predicts the unlabelled data using PyTorch. File 5_3_da provides software requirements from a Google Colab runtime.

Since the code primarily covers basic and widely applied data wrangling and machine learning routines, the author refrains from explicitly licensing the code.
When using this code or adapted versions of it for purposes in line with those of the technical paper, please cite the paper.

Feedback is welcome.

