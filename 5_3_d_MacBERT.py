# Technical Paper:
# Text Mining and Document Classification Workflows for Chinese Administrative Documents
# File 5.3.d - Transformers: Fine-Tuning and Prediction with Chinese MacBERT (large)



print("step 1: loading packages and data")

# packages
import os
import numpy as np
import pandas as pd
from sklearn.utils import resample
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from transformers import AdamW
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
from tqdm import tqdm
from torch.utils.data import Dataset
from torch.utils.data import DataLoader


# Load the data 
# Y
y_train = pd.read_csv('/home/amueller/dta_health/y_broad_train.csv')['y_broad']
y_test = pd.read_csv('/home/amueller/dta_health/y_broad_test.csv')['y_broad']
print(y_train.value_counts())

# X
x_train = pd.read_csv('/home/amueller/dta_health/X_sen_train.csv', header=0)
x_test = pd.read_csv('/home/amueller/dta_health/X_sen_test.csv', header=0)
x_unlabelled = pd.read_csv('/home/amueller/dta_health/X_sen_unlabelled.csv', header=0)
print(x_test.head())


print("step 2: data preparation")

# 2.1 Split off validation data
x_train2, x_val, y_train2, y_val = train_test_split(x_train, y_train,
                                                    test_size=0.3, stratify=y_train, random_state=42)

# 2.2 Upsampling
# Select the minority class samples
minority_class_samples = x_train2[y_train2 == 1]
# Extract the corresponding labels for the minority class samples.
minority_class_labels = y_train2[y_train2 == 1]
# Upsample the minority class to match the majority class
X_upsampled, y_upsampled = resample(minority_class_samples, # upsample the minority class samples
                                    minority_class_labels, # upsample labels
                                    replace=True, # add more to the original number of samples
                                    n_samples=x_train2[y_train2 == 0].shape[0], # specifies the desired number of samples, set to the number of samples in the majority class.
                                    random_state=123) # set a seed for reproducibility.
print('Number of class 1 examples after:', X_upsampled.shape[0])

# Put dataframes together again
X_bal = np.vstack((x_train2[y_train2 == 0], X_upsampled))
y_bal = np.hstack((y_train2[y_train2 == 0], y_upsampled))
X_bal.shape




print("... loading model and tokenizer ...")

# 2.3 Load Chinese MacBERT
model_name = "hfl/chinese-macbert-large"  # (replace with other model if needed)
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name, num_labels=2)


print(" ... commencing tokenization ...")

# Define tokenizing function
class TextDataset(Dataset):
    def __init__(self, texts, labels, tokenizer, max_length=300): # adjust max_length if needed
        """
        Args:
            texts (list): List of text samples (X).
            labels (list): List of labels (y).
            tokenizer: Hugging Face tokenizer.
            max_length (int): Maximum token length.
        """
        self.texts = texts
        self.labels = labels
        self.tokenizer = tokenizer
        self.max_length = max_length 

    def __len__(self):
        return len(self.texts)

    def __getitem__(self, idx):
        text = str(self.texts[idx])
        label = int(self.labels[idx])

        # Tokenization
        encoding = self.tokenizer(
            text, padding="max_length", truncation=True, max_length=self.max_length, return_tensors="pt"
        )

        return {
            "input_ids": encoding["input_ids"].squeeze(0),
            "attention_mask": encoding["attention_mask"].squeeze(0),
            "labels": torch.tensor(label, dtype=torch.long),
        }


# Create datasets
train_dataset = TextDataset(X_bal.flatten(), np.array(y_bal).flatten(), tokenizer)
val_dataset = TextDataset(np.array(x_val['sentences']).flatten(), np.array(y_val).flatten(), tokenizer)
test_dataset = TextDataset(np.array(x_test['sentences']).flatten(), np.array(y_test).flatten(), tokenizer)


# Data loader
batch_size = 16
train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)
test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)


print("Step 3: Set Up Training")

# Use AdamW optimizer, cross-entropy loss, and GPU acceleration (if available).

# Move model to GPU if available
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)

# Define optimizer and loss function
optimizer = AdamW(model.parameters(), lr=5e-5)
criterion = torch.nn.CrossEntropyLoss()

# Training Loop with standard backpropagation and early stopping

# Early stopping parameters
patience = 8  # Number of epochs to wait before stopping
best_val_loss = np.inf  # Initialize with a high value
patience_counter = 0  # Track number of epochs without improvement

epochs = 50  

# Training Loop:
for epoch in range(epochs):
    model.train() # set the model to training mode
    total_loss = 0 # initialize total loss

    # create progress bar (loop structure and visual output)
    progress_bar = tqdm(train_loader, desc=f"Epoch {epoch+1}")

    # Loop over the badges in the progress bar
    for batch in progress_bar:
        input_ids = batch["input_ids"].to(device) # move data to CPU/GPU
        attention_mask = batch["attention_mask"].to(device)
        labels = batch["labels"].to(device)

        optimizer.zero_grad() # reset the gradients

        # Forward pass (make predictors, calculate loss)
        outputs = model(input_ids, attention_mask=attention_mask, labels=labels)
        loss = outputs.loss
        total_loss += loss.item()

        # Backward pass (calculate gradients, update parameters)
        loss.backward()
        optimizer.step()

        progress_bar.set_postfix(loss=loss.item()) # display loss value of current batch

    # Calculate and print average loss for the epoch
    avg_loss = total_loss / len(train_loader)
    print(f"Epoch {epoch+1} completed. Average Loss: {avg_loss:.4f}")


    # Validation:
    model.eval()  # Set model to eval mode (no gradient updates)
    val_loss = 0

    with torch.no_grad():  # No need to compute gradients
        for batch in val_loader:
            input_ids = batch["input_ids"].to(device)
            attention_mask = batch["attention_mask"].to(device)
            labels = batch["labels"].to(device)

            outputs = model(input_ids, attention_mask=attention_mask, labels=labels)
            val_loss += outputs.loss.item()

    avg_val_loss = val_loss / len(val_loader)
    print(f"Epoch {epoch+1} Validation Loss: {avg_val_loss:.4f}")



    # Early Stopping:
    if avg_val_loss < best_val_loss:
        best_val_loss = avg_val_loss
        patience_counter = 0  # Reset counter if loss improves
        torch.save(model.state_dict(), "best_model.pth")  # Save best model
    else:
        patience_counter += 1  # Increment counter if no improvement
        print(f"Early Stopping Counter: {patience_counter}/{patience}")

    if patience_counter >= patience:
        print("Early stopping triggered. Training stopped.")
        break  # Stop training if patience is exceeded


print("recover and save the best model")
model.load_state_dict(torch.load("best_model.pth"))

torch.save(model.state_dict(), "/home/amueller/dta_health/Health_MacBERT_len300_50ep_8es.pth")

print("step 4: validation")

# Evaluation: Accuracy & Sensitivity

def evaluate(model, dataloader, device):
    model.eval()  # Set model to evaluation mode
    total_correct = 0
    total_samples = 0

    TP = 0  # True Positives
    FN = 0  # False Negatives

    all_preds = []
    all_labels = []

    with torch.no_grad():  # Disable gradient computation
        for batch in dataloader:
            input_ids = batch["input_ids"].to(device)
            attention_mask = batch["attention_mask"].to(device)
            labels = batch["labels"].to(device)

            outputs = model(input_ids, attention_mask=attention_mask)
            logits = outputs.logits
            predictions = torch.argmax(logits, dim=1)  # Get predicted class

            total_correct += (predictions == labels).sum().item()
            total_samples += labels.size(0)

            # Convert to CPU for computation
            predictions = predictions.cpu().numpy()
            labels = labels.cpu().numpy()

            # Store for global metrics
            all_preds.extend(predictions)
            all_labels.extend(labels)

            # Compute TP & FN
            TP += ((predictions == 1) & (labels == 1)).sum()  # True Positives
            FN += ((predictions == 0) & (labels == 1)).sum()  # False Negatives

    accuracy = total_correct / total_samples
    sensitivity = TP / (TP + FN) if (TP + FN) > 0 else 0  # Avoid division by zero

    return accuracy, sensitivity

val_accuracy, val_sensitivity = evaluate(model, val_loader, device)

print(f"Validation Accuracy: {val_accuracy:.4f}")
print(f"Validation Sensitivity (Recall for Positive Class): {val_sensitivity:.4f}")

print("step 5: testing")

test_accuracy, test_sensitivity = evaluate(model, test_loader, device)

print(f"Test Accuracy: {test_accuracy:.4f}")
print(f"Test Sensitivity (Recall for Positive Class): {test_sensitivity:.4f}")


print("step 5: prediction")

def classify_text_batch_with_manual_batching(texts, model, tokenizer, device, batch_size=32, max_length=300):
    model.eval()  # Set the model to evaluation mode
    all_predictions = []  # Initialize an empty list to store predictions

    for i in range(0, len(texts), batch_size):
        batch_texts = texts[i : i + batch_size]  # Get the current batch of texts

        # Ensure batch_texts is a list of strings
        batch_texts = [str(text) for text in batch_texts]

        encodings = tokenizer(
            batch_texts,  # Pass batch_texts as a list of sentences
            return_tensors="pt",
            truncation=True,
            padding=True,
            max_length=max_length,  # Pass max_length to the tokenizer
        )

        input_ids = encodings["input_ids"].to(device)
        attention_mask = encodings["attention_mask"].to(device)

        with torch.no_grad():
            outputs = model(input_ids, attention_mask=attention_mask)
            logits = outputs.logits
            predictions = torch.argmax(logits, dim=1).cpu().numpy()

        all_predictions.extend(predictions)

    labels = ["Positive" if pred == 1 else "Negative" for pred in all_predictions]
    return labels

# get the sentences
sentences = x_unlabelled['sentences'].tolist()

# predict labels for unlabelled sentences
predicted_labels = classify_text_batch_with_manual_batching(sentences, model, tokenizer, device, max_length=300)

# add labels to dataset
x_unlabelled['pred_chinMacBERT'] = predicted_labels

x_unlabelled['pred_chinMacBERT'].value_counts()

# save the data
x_unlabelled.to_csv('/home/amueller/dta_health/X_sen_unlabelled_chinMacB.csv', index=False)