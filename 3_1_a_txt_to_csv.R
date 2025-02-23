# Gather text files in a database

library(tidyverse)
library(readtext)


# 1. set working directory to folder with unzipped files

file.choose()
setwd("D:\\10a_TXT_Data\\PKUlaw\\Gesundheitswesen\\unzipped\\")
getwd()


# 2. create a data set from the files
#  make a list of the txt documents
filelist = list.files(pattern = "*.txt")
filelist

## format it as a data frame
filelist_df <- as.data.frame(filelist)
glimpse(filelist_df)

## create a column called text and one called doc_id
filelist_df$doc_id <- as.character(NA)
filelist_df$text <- as.character(NA)
colnames(filelist_df) <- c("file", "doc_id", "text")
filelist_df





# fill the text field
## check readtext() output
readtext(filelist_df$file[5])[1] # document ID
readtext(filelist_df$file[5])[2] # text

# fill doc_id and text
for (i in 1:length(filelist)){
  filelist_df$doc_id[i] <- readtext(filelist_df$file[i])[1][1,1]
  filelist_df$text[i] <- readtext(filelist_df$file[i])[2][1,1]
  print(paste("completed file ", i))
}
#warnings()
class(filelist_df$text)


# Individual files may cause problems, for example because they are empty.
# The easiest way to avoid those is to create sub-loops

# Step 1: 
for (i in 1:10050){
  filelist_df$doc_id[i] <- readtext(filelist_df$file[i])[1][1,1]
  filelist_df$text[i] <- readtext(filelist_df$file[i])[2][1,1] # unlist: siehe 2.4.1
  print(paste("completed file ", i))
}

# number 10051 creates an error

for (i in 10052:15253){
  filelist_df$doc_id[i] <- readtext(filelist_df$file[i])[1][1,1]
  filelist_df$text[i] <- readtext(filelist_df$file[i])[2][1,1] # unlist: siehe 2.4.1
  print(paste("completed file ", i))
}

# number 15254 creates an error
for (i in 15255:20000){
  filelist_df$doc_id[i] <- readtext(filelist_df$file[i])[1][1,1]
  filelist_df$text[i] <- readtext(filelist_df$file[i])[2][1,1] # unlist: siehe 2.4.1
  print(paste("completed file ", i))
}


for (i in 20001:31139){
  filelist_df$doc_id[i] <- readtext(filelist_df$file[i])[1][1,1]
  filelist_df$text[i] <- readtext(filelist_df$file[i])[2][1,1] # unlist: siehe 2.4.1
  print(paste("completed file ", i))
}



# delete redundant information
filelist_df$file <- NULL

## turn into tibble and 
filelist_df <- tibble(filelist_df)



# 3. Save the file

#setwd("/Users/arminmuller/Documents/PKUlaw/Gesundheitswesen/")
setwd("/media/armin/DATA/10a - TXT Data/PKUlaw/Gesundheitswesen/")

save(filelist_df,
     file = "healthcare_docs_20230725.rda")

write.csv(filelist_df,
          file = "healthcare_docs_20230725.csv",
          row.names = F)


# 3.1 slim version for database
glimpse(filelist_df)

filelist_df_slim <- filelist_df %>%
  select(-text, -text_work)


save(filelist_df_slim,
     file = "healthcare_slim_20230727.rda")

write.csv(filelist_df_slim,
          file = "healthcare_slim_20230727.csv",
          row.names = F)

