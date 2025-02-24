
# 1) load database

library(tidyverse)
library(jiebaR)
library(tidytext)


setwd("D:\\10a_TXT_Data\\PKUlaw\\Gesundheitswesen\\")
filelist_df <- read.csv(file = "healthcare_docs_20231123.csv", header=TRUE)
head(filelist_df)

# inspect the data
head(filelist_df)
View()

# set seed for reproducability
set.seed(421)

# 1) create random document number
filelist_df$ran200doc <- floor(runif(31139, min=1, max=200))
glimpse(filelist_df)




# 2) split the data into sentences

?str_split()
# split along "。"; 
# there are not many question and exclamation marks in administrative documents.

health_sentences <- filelist_df %>%
  select(doc_index, ran200doc, text_clean) %>%
  mutate(sentences = str_split(text_clean, "。")) %>%
  select(-text_clean) %>%
  group_by(doc_index) %>%
  unnest(sentences)
  
head(health_sentences)
glimpse(health_sentences)



# 3) create a random sentence number

# Generate random numbers from 1 to 20 for each sentence

# Option 1: random sentence number accross documents
# health_sentences$ran20sen <- floor(runif(1003136, min=1, max=20))


# Option 2: random sentence number nested in documents
?sample()
health_sentences <- health_sentences %>%
  group_by(doc_index) %>%
  mutate(ran20sen = sample(1:20, n(), replace = TRUE))

glimpse(health_sentences)


# generate a unique sentence identifier
health_sentences$sen_index  <- seq.int(nrow(health_sentences))
glimpse(health_sentences)

# save the results
write.csv(health_sentences,
          file = "health_sentences_20231123.csv",
          row.names = F)

# load the results
health_sentences <- read.csv(file = "health_sentences_20231123.csv", header=TRUE)




# 4) Training data

# Randomly select sentences for training data.
# The batches should contain about 1000 sentences each, with a generous margin of error.

summary(health_sentences$ran200doc)
summary(health_sentences$ran20sen)


# 3.1 Set 1 - November 23, 2023
Training_dta1 <- health_sentences %>%
  filter(ran200doc <=2) %>%
  filter(ran20sen <=2)

glimpse(Training_dta1)

write.csv(Training_dta1,
          file = "Training_dta1_20231123.csv",
          row.names = F)


Training_dta2 <- health_sentences %>%
  filter(ran200doc >2 & ran200doc <=4) %>%
  filter(ran20sen >2 & ran20sen <=4)

write.csv(Training_dta2,
          file = "Training_dta2_20231123.csv",
          row.names = F)



Training_dta3 <- health_sentences %>%
  filter(ran200doc >4 & ran200doc <=6) %>%
  filter(ran20sen >4 & ran20sen <=6)

write.csv(Training_dta3,
          file = "Training_dta3_20231123.csv",
          row.names = F)



# 3.2 Set 2 - December 14, 2023

Training_dta4 <- health_sentences %>%
  filter(ran200doc >6 & ran200doc <=8) %>%
  filter(ran20sen >6 & ran20sen <=8)

write.csv(Training_dta4,
          file = "Training_dta4_20231214.csv",
          row.names = F)

Training_dta5 <- health_sentences %>%
  filter(ran200doc >8 & ran200doc <=10) %>%
  filter(ran20sen >8 & ran20sen <=10)

write.csv(Training_dta5,
          file = "Training_dta5_20231214.csv",
          row.names = F)


Training_dta6 <- health_sentences %>%
  filter(ran200doc >10 & ran200doc <=12) %>%
  filter(ran20sen >10 & ran20sen <=12)

write.csv(Training_dta6,
          file = "Training_dta6_20231214.csv",
          row.names = F)



# 3.2 Set 3 - January 9, 2024
  

Training_dta7 <- health_sentences %>%
  filter(ran200doc >12 & ran200doc <=14) %>%
  filter(ran20sen >12 & ran20sen <=14)

write.csv(Training_dta7,
          file = "Training_dta7_20240109.csv",
          row.names = F)

Training_dta8 <- health_sentences %>%
  filter(ran200doc >14 & ran200doc <=16) %>%
  filter(ran20sen >14 & ran20sen <=16)
         
write.csv(Training_dta8,
         file = "Training_dta8_20240109.csv",
         row.names = F)

Training_dta9 <- health_sentences %>%
  filter(ran200doc >16 & ran200doc <=18) %>%
  filter(ran20sen >16 & ran20sen <=18)
         
write.csv(Training_dta9,
         file = "Training_dta9_20240109.csv",
         row.names = F)



# 3.3 Set 4 - January 29, 2024


Training_dta10 <- health_sentences %>%
  filter(ran200doc >18 & ran200doc <=20) %>%
  filter(ran20sen >18 & ran20sen <=20)

write.csv(Training_dta10,
          file = "Training_dta10_20240129.csv",
          row.names = F)


Training_dta11 <- health_sentences %>%
  filter(ran200doc >20 & ran200doc <=22) %>%
  filter(ran20sen >0 & ran20sen <=2)

write.csv(Training_dta11,
          file = "Training_dta11_20240129.csv",
          row.names = F)


Training_dta12 <- health_sentences %>%
  filter(ran200doc >22 & ran200doc <=24) %>%
  filter(ran20sen >2 & ran20sen <=4)

write.csv(Training_dta12,
          file = "Training_dta12_20240129.csv",
          row.names = F)



# 3.3 Set 4 - February 26, 2024


Training_dta13 <- health_sentences %>%
  filter(ran200doc >24 & ran200doc <=26) %>%
  filter(ran20sen >4 & ran20sen <=6)

write.csv(Training_dta13,
          file = "Training_dta13_20240226.csv",
          row.names = F)


Training_dta14 <- health_sentences %>%
  filter(ran200doc >26 & ran200doc <=28) %>%
  filter(ran20sen >6 & ran20sen <=8)

write.csv(Training_dta14,
          file = "Training_dta14_20240226.csv",
          row.names = F)


Training_dta15 <- health_sentences %>%
  filter(ran200doc >28 & ran200doc <=30) %>%
  filter(ran20sen >8 & ran20sen <=10)

write.csv(Training_dta15,
          file = "Training_dta15_20240226.csv",
          row.names = F)



## 3.4 Set 5: March 18


Training_dta16 <- health_sentences %>%
  filter(ran200doc >30 & ran200doc <=32) %>%
  filter(ran20sen >6 & ran20sen <=8)

write.csv(Training_dta16,
          file = "Training_dta16_20240318.csv",
          row.names = F)


Training_dta17 <- health_sentences %>%
  filter(ran200doc >32 & ran200doc <=34) %>%
  filter(ran20sen >8 & ran20sen <=10)

write.csv(Training_dta17,
          file = "Training_dta17_20240318.csv",
          row.names = F)


Training_dta18 <- health_sentences %>%
  filter(ran200doc >34 & ran200doc <=36) %>%
  filter(ran20sen >10 & ran20sen <=12)

write.csv(Training_dta18,
          file = "Training_dta18_20240318.csv",
          row.names = F)

# 3.5 Set 6: April 10 2024

Training_dta19 <- health_sentences %>%
  filter(ran200doc >36 & ran200doc <=38) %>%
  filter(ran20sen >12 & ran20sen <=14)

write.csv(Training_dta19,
          file = "Training_dta19_20240410.csv",
          row.names = F)

Training_dta20 <- health_sentences %>%
  filter(ran200doc >38 & ran200doc <=40) %>%
  filter(ran20sen >14 & ran20sen <=16)

write.csv(Training_dta20,
          file = "Training_dta20_20240410.csv",
          row.names = F)

Training_dta21 <- health_sentences %>%
  filter(ran200doc >40 & ran200doc <=42) %>%
  filter(ran20sen >16 & ran20sen <=18)

write.csv(Training_dta21,
          file = "Training_dta21_20240410.csv",
          row.names = F)



