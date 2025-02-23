

library(tidyverse)
library(tidytext)

# 1. load data
setwd("D:\\10a_TXT_Data\\PKUlaw\\Gesundheitswesen\\")

filelist_df <- read.csv(file = "healthcare_docs_20230725.csv", header=TRUE)
load(file = "healthcare_docs_20230725.rda")
print(filelist_df)

head(filelist_df)


# 2. Extract information and clean the data

# the following information will be extracted and saved in separate columns
## 1. PKUlaw ID
## 2. PKUlaw URL
## 3. Title
## 4. Document identifyer
## 5. Prefectural jurisdiction
## 6. Provincial jurisdiction


# retain a backup of the original text in case of problems
filelist_df$text_work <- filelist_df$text


## 2.1 Extract the PKUlaw document number

## develop a regular expression
# 【法宝引证码】 CLI.14.618767\n
str_view(filelist_df$text_work[1], "【法宝引证码】")
str_view(filelist_df$text_work[1], "【法宝引证码】\\s...\\.\\d+\\.\\d+\n")
str_view(filelist_df$text_work[1], "\\s...\\.\\d+\\.\\d+\n")
str_view(filelist_df$text_work[2], "\\s...\\.\\d+\\.\\d+")


## Extract PKUlaw ID
filelist_df$pkulaw_id <- str_extract(filelist_df$text_work, "...\\.\\d+\\.\\d+")
head(filelist_df$pkulaw_id)
summary(is.na(filelist_df$pkulaw_id)) # 2 NAs
tail(filelist_df$pkulaw_id)        

## Delete PKUlaw ID in the text
filelist_df$text_work <- str_replace(filelist_df$text_work, "【法宝引证码】\\s...\\.\\d+\\.\\d+\n", "")
filelist_df$text_work[1]

## save a copy
write.csv(filelist_df,
          file = "healthcare_docs_20230725.csv",
          row.names = F)


# 2.2 Extract the PKUlaw URL

## develop regex
str_view(filelist_df$text_work[6], "\\s+原文链接：https://www.pkulaw.com/.../([^ ]+)html\n")


# extract PKUlaw link 
filelist_df$link <- str_extract(filelist_df$text_work, "https://www.pkulaw.com/.../([^ ]+)html")
head(filelist_df$link)
summary(is.na(filelist_df$link)) #
tail(filelist_df$link) 

# try alternative URL to fill NAs:
filelist_df$link[is.na(filelist_df$link)] <- str_extract(filelist_df$text_work[is.na(filelist_df$link)],
                                                         "\\s?原文链接：http://([^ ]+)html\n")



## inspect NAs
inspect <- filelist_df %>%
  filter(is.na(filelist_df$link))
tibble(inspect)
inspect$text_work
View(inspect)


## delete PKUlaw URLS in the text
filelist_df$text_work <- str_replace(filelist_df$text_work, "\\s+原文链接：https://www.pkulaw.com/.../([^ ]+)html\n", "")
filelist_df$text_work <- str_replace(filelist_df$text_work, "\\s?原文链接：http://([^ ]+)html\n", "")
filelist_df$text_work[1]

## save
write.csv(filelist_df,
          file = "healthcare_docs_20230725.csv",
          row.names = F)


# 2.3 first date mentioned

## develop regex
str_view(filelist_df$text_work[2], "....年.+月.+日")

## extract
filelist_df$first_date <- str_extract(filelist_df$text_work, "....年.{1,2}月.{1,2}日")
head(filelist_df$first_date)
summary(is.na(filelist_df$first_date))
tail(filelist_df$first_date)

## inspect results
inspect <- filelist_df %>%
  filter(!is.na(filelist_df$first_date)) %>%
  select(-text, -pkulaw_id, -link)
tibble(inspect)  
View(inspect)

## date is not removed because it may be an important part of the text

## cleaning first date
filelist_df$first_date
as_date(filelist_df$first_date) # failed to parse 4291 lines

## Convert Chinese numbers to latin numbers
filelist_df$first_date2 <- filelist_df$first_date
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "三十一", "31")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "三十", "30")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二十九", "29")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二十八", "28")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二十七", "27")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二十六", "26")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二十五", "25")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二十四", "24")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二十三", "23")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二十二", "22")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二十一", "21")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二十", "20")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "十九", "19")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "十八", "18")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "十七", "17")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "十六", "16")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "十五", "15")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "十四", "14")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "十三", "13")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "十二", "12")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "十一", "11")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "十", "10")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "九", "9")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "八", "8")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "七", "7")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "六", "6")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "五", "5")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "四", "4")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "三", "3")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "二", "2")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "一", "1")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "○", "0")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "零", "0")
as_date(filelist_df$first_date2) # failed to parse 2048

## check the remaining entries and change numbers that are not properly recognized
filelist_df$first_date2[is.na(as_date(filelist_df$first_date2))] # check remaining entries
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "〇", "0")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "９", "9")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "８", "8")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "７", "7")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "６", "6")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "５", "5")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "４", "4")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "３", "3")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "２", "2")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "１", "1")
as_date(filelist_df$first_date2) # failed to parse 1254
filelist_df$first_date2[is.na(as_date(filelist_df$first_date2))] # check remaining entries
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "０", "0")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "Ｏ", "0")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "O", "0")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "О", "0")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "Ο", "0")
filelist_df$first_date2 <- str_replace_all(filelist_df$first_date2, "l", "1")


as_date(filelist_df$first_date2) # failed to parse 738
filelist_df$first_date2[is.na(as_date(filelist_df$first_date2))] # check remaining entries
# save the final version of the formatted date
filelist_df$first_date_formated <- as_date(filelist_df$first_date2)





# 2.4 Document identifiers

# extract document identifiers before headlines so they do not feature there
# example: （七政办发〔2011〕38号）

# develop a regex:
str_view(filelist_df$text_work[1], "([^ ,\n, )]{2,6})[^ ]\\d{4}[^ ]\\d+[号]")
str_view(filelist_df$text_work[2], "([^ ,\n]{2,6})[^ ]\\d{4}[^ ]\\d+[号]")
str_view(filelist_df$text_work[555], "([^ ,\n]{2,6})[^ ]\\d{4}[^ ]\\d+[号]")

# extract
filelist_df$abbreviation <- str_extract(filelist_df$text_work, "([^ ,\n, (, （, \\d，　,﹙, 》, 。, L,]{2,6})[^ ]\\d{4}[^ ]\\d+[号]")
head(filelist_df$abbreviation)
summary(is.na(filelist_df$abbreviation)) # 3410 NAs
tail(filelist_df$abbreviation) 

## check the results
print(filelist_df$abbreviation)
## ri - Tag; aber auch Rizhao
View(filelist_df)
# The identifiers are correct with a few exceptions

# count abbreviations
filelist_df %>%
  group_by(abbreviation) %>%
  select(abbreviation) %>%
  summarise(n())


## extract document number from the identifyer
str_view(filelist_df$abbreviation[100], "\\d+[号]")
filelist_df$number <- str_extract(filelist_df$abbreviation, "\\d+[号]")
filelist_df$number <- filelist_df$number %>% str_remove_all("号")
filelist_df$abbreviation <- str_replace(filelist_df$abbreviation, "\\d+[号]", "")


# extract the year the document was enacted
str_view(filelist_df$abbreviation[1], "[^ ]\\d{4}[^ ]")
filelist_df$year <- str_extract(filelist_df$abbreviation, "[^ ]\\d{4}[^ ]")
summary(is.na(filelist_df$year)) # 4122 NAs
filelist_df$year <- str_extract(filelist_df$year, "\\d{4}")
filelist_df$abbreviation <- str_replace(filelist_df$abbreviation, "[^ ]\\d{4}[^ ]", "")


## inspect abbreviations
inspect <- filelist_df %>%
  group_by(abbreviation) %>%
  select(abbreviation) %>%
  summarise(n())
View(inspect)
# 3902 abbreviations, some are too short or to long

## inspect NAs
inspect <- filelist_df %>%
  filter(is.na(filelist_df$abbreviation)) %>%
  select(-text, -doc_id, -pkulaw_id, -link )
tibble(inspect)  
View(inspect)
## some documents lack the information



# 2.5 Titles

# After extracting the previous information, the document title is now in the first line.
# Titles can be exceedingly long, so a large number of characters should be allowed for the match.

## develop regex
filelist_df$text_work[1]
str_view(filelist_df$text_work[1], "^.{5,400}\n")

filelist_df$text_work[2]
str_view(filelist_df$text_work[2], "^.{5,400}\n")

filelist_df$text_work[555]
str_view(filelist_df$text_work[555], "^.{5,400}\n")


## extract
filelist_df$title <- str_extract(filelist_df$text_work, "^.{5,400}\n") # extract first line
filelist_df$title <- filelist_df$title %>% str_remove_all("\n") # remove line breaks
filelist_df$title <- filelist_df$title %>% str_remove_all("  ") # remove spaces
head(filelist_df$title)

summary(is.na(filelist_df$title)) # 9 NAs
tail(filelist_df$title) 

## check the titles 
inspect <- filelist_df %>%
  filter(!is.na(filelist_df$title)) %>%
  select(-text, -doc_id, -pkulaw_id, -link )
tibble(inspect)  
View(inspect)

## check if document identifiers were matched

summary(str_detect(filelist_df$title, "([^ ,\n, (, （, \\d，　,﹙, 》, 。, L,]{2,6})[^ ]\\d{4}[^ ]\\d+[号]"))
inspect %>%
  filter(str_detect(title, "([^ ,\n, (, （, \\d，　,﹙, 》, 。, L,]{2,6})[^ ]\\d{4}[^ ]\\d+[号]")==TRUE) %>%
  select(title) %>%
  str_view("([^ ,\n, (, （, \\d，　,﹙, 》, 。, L,]{2,6})[^ ]\\d{4}[^ ]\\d+[号]")
  
  
## delete the identifyers
filelist_df$title <- str_replace(filelist_df$title, "([^ ,\n, (, （, \\d，　,﹙, 》, 。, L,]{2,6})[^ ]\\d{4}[^ ]\\d+[号]", "")

## clean




# 2.6 Prefecture
# The remaining document text typically starts by reiterating the heading.
# Documents enacted by prefectural jurisdictions often start with the name of the prefectural city,
# or mention it early on.
# Prefectural jurisdictions typically end with the characters 市, 自治州, 州 or 盟.
# The length of the names may vary considerably, but most names are between 1 and 4 characters.

## extract potential names of prefectures 
filelist_df$city_prefecture <- str_extract(filelist_df$title, ".{1,4}市")
filelist_df$city_prefecture[is.na(filelist_df$city_prefecture)] <- str_extract(filelist_df$title[is.na(filelist_df$city_prefecture)], ".{1,4}自治州")
filelist_df$city_prefecture[is.na(filelist_df$city_prefecture)] <- str_extract(filelist_df$title[is.na(filelist_df$city_prefecture)], ".{1,4}州")
filelist_df$city_prefecture[is.na(filelist_df$city_prefecture)] <- str_extract(filelist_df$title[is.na(filelist_df$city_prefecture)], ".{1,4}盟")
print(filelist_df$city_prefecture)
summary(is.na(filelist_df$city_prefecture))

## inspect and clean names of prefectures
### round 1
table(filelist_df$city_prefecture)
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "、", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "发《", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "中共", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "先进县\\(市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "关于", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "《", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "市市", "市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "总局", "")
table(filelist_df$city_prefecture)

# round 2
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "年度", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "黑龙江省市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "面建立城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "障省内跨市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "随州随州", "随州")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "险试点城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "险实行州市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "险公司城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "险公司地市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "院和", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "院与", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "..省市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "金平县城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "重庆五省市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "郑州", "郑州市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "进旗县\\(市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "辽阳市城市", "辽阳市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "辽宁省市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "辽宁省城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "转贵州", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "转发", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "费试点城市", "")
table(filelist_df$city_prefecture)

# round 3
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "面实施城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "\\+N”联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "“", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "\\d", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "个县\\(市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "年", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "一步加强市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "东省际联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "东区域联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "院\\(", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "\\(", "")
table(filelist_df$city_prefecture)

# round 4
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "”", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "N", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "5个县市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "4大连市", "大连市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "＋联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "\\+联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "中成药联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "临夏州", "临夏回族自治州")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "临夏州城市", "临夏回族自治州")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "于做", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "于对", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "于将市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "于张家口市", "张家口市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "于防城港市", "防城港市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "于在福州市", "福州市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "于...市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "于将市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "作...市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "促进", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "保险...", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "做好", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "公司", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "先进县市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "公布", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "医疗...", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "..省联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "印发", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "县城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "同意", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "和广东联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "和浩特四市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "和省际联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "和规范城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "品采购联盟 ", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "国家联盟", "")
table(filelist_df$city_prefecture)


# round 5
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, ".省", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "临夏回族自治州城市", "临夏回族自治州")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "京津冀联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "农合...", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "准石家庄市", "石家庄市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "务贵州", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "厅上海市", "上海市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "助制度盟市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "动示范城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "医疗县市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "参加", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "取消", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "合作医疗市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "生育保险市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "甘肃省城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "省广东联盟消", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "级采购联盟", "")
table(filelist_df$city_prefecture)

# round 6
#filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "重", "")
#filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "临夏回族自治州[城市]+", "临夏回族自治州")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "于完善贵州", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "于阿拉善盟", "阿拉善盟")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "厅.+", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "台在", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "员赴", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "品采购联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "域农民工市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "增补南昌市", "南昌市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "声刀头联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "大同市城市", "大同市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "大试点城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "大连市城市", "大连市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "好城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "好广东联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "好重庆联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "实", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "家试点城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "密地区城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "对.+", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "局", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, ".+联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "工作先进市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "影响助力市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "意将泉州市", "泉州市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "成立", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "报送市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, ".+区市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "撤销", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "政协", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "效]", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "文山州城市", "文山州")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "新农合盟市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "新增", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "新批", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "本市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "本溪市城市", "本溪市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "权委托盟市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "构采购联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "止石家庄市", "石家庄市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "步.+", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "民银行兰州", "兰州市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "民银行广州", "广州市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "民银行杭州", "杭州市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "点联系城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "用耗材联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "疗保险州市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "疗机构联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "省广东联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "省区市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "省开展城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "第...市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "纳入", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "级试点城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "级和设区市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "级及杭州市", "杭州市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "药大学杭州", "杭州市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "药采购联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "行广东联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "西部地区市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "规范药品市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "解决", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "解除", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "试点县市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "试验区钦州", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "调整", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "贵州", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "转合肥市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "进旗县市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "郑州市市", "郑州市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "部片区联盟", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "金昌市城市", "金昌市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "银行", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "险扩大城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "马鞍市", "马鞍山市")
table(filelist_df$city_prefecture)


# round 7
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "会济南市", "济南市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "为葫芦岛市", "葫芦岛市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "件的合肥市", "合肥市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "各市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "项目实行市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "委台州市", "台州市")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "妨碍统一市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "委员会", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^山$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "月7日市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^重$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^河$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^疗$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^自治$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "确定", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^确市$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^自治$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "自治区地州", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "自治区城市", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^自治州$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^药$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^行$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^赛尔$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^重$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^做$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, "^市$", "")
filelist_df$city_prefecture <- str_replace(filelist_df$city_prefecture, " ", "")
table(filelist_df$city_prefecture)


# 2.7 Province
# The procedure is similar to that for prefectural cities.
# The Autonomous Regions (自治区) were added later via SQL query.

## extract potential province names
filelist_df$province <- NA
filelist_df$province <- str_extract(filelist_df$title, "([^ ,我,《,发,行,属,外,跨,本,、,省,施,于,给,全,两,＜,7,彻,局,实,厅,驻]{1,3})省")
filelist_df$province[is.na(filelist_df$province)] <- str_extract(filelist_df$title[is.na(filelist_df$province)], "(上海|北京|天津|重庆)")
print(filelist_df$province[!is.na(filelist_df$province)])
table(filelist_df$province)

## clean the data
# round 1
filelist_df$province <- str_replace(filelist_df$province, "“", "")
filelist_df$province <- str_replace(filelist_df$province, "[1234567890]", "")
filelist_df$province <- str_replace(filelist_df$province, "年", "")
filelist_df$province <- str_replace(filelist_df$province, "下达省", "")
filelist_df$province <- str_replace(filelist_df$province, "中..省", "")
filelist_df$province <- str_replace(filelist_df$province, "从江苏省", "江苏省")
filelist_df$province <- str_replace(filelist_df$province, "体系和省", "")
filelist_df$province <- str_replace(filelist_df$province, "保险的省", "")
filelist_df$province <- str_replace(filelist_df$province, "做好.?省", "")
filelist_df$province <- str_replace(filelist_df$province, "健康委省", "")
filelist_df$province <- str_replace(filelist_df$province, "入", "")
filelist_df$province <- str_replace(filelist_df$province, "共", "")
filelist_df$province <- str_replace(filelist_df$province, "公布省", "")
filelist_df$province <- str_replace(filelist_df$province, "分批次省", "")
filelist_df$province <- str_replace(filelist_df$province, "加快省", "")
filelist_df$province <- str_replace(filelist_df$province, "务圈”省", "")
filelist_df$province <- str_replace(filelist_df$province, "医保省", "")
filelist_df$province <- str_replace(filelist_df$province, "十二省", "")
filelist_df$province <- str_replace(filelist_df$province, "卫健委省", "")
filelist_df$province <- str_replace(filelist_df$province, "司", "")
filelist_df$province <- str_replace(filelist_df$province, "员", "")
filelist_df$province <- str_replace(filelist_df$province, "和十三省", "")
filelist_df$province <- str_replace(filelist_df$province, "和清算省", "清算省")
filelist_df$province <- str_replace(filelist_df$province, "和省", "")
filelist_df$province <- str_replace(filelist_df$province, "品..省", "")
filelist_df$province <- str_replace(filelist_df$province, "善", "")
filelist_df$province <- str_replace(filelist_df$province, "四部门省", "")
filelist_df$province <- str_replace(filelist_df$province, "国家和省", "")
filelist_df$province <- str_replace(filelist_df$province, "在", "")
filelist_df$province <- str_replace(filelist_df$province, "增设省", "")
filelist_df$province <- str_replace(filelist_df$province, "好上线省", "")
filelist_df$province <- str_replace(filelist_df$province, "好..省", "")
filelist_df$province <- str_replace(filelist_df$province, "宁..省", "")
filelist_df$province <- str_replace(filelist_df$province, "定", "")
filelist_df$province <- str_replace(filelist_df$province, "对", "")
filelist_df$province <- str_replace(filelist_df$province, "将", "")
filelist_df$province <- str_replace(filelist_df$province, "展..省", "")
filelist_df$province <- str_replace(filelist_df$province, "川等8省", "")
filelist_df$province <- str_replace(filelist_df$province, "市上线省", "")
filelist_df$province <- str_replace(filelist_df$province, "布", "")
filelist_df$province <- str_replace(filelist_df$province, "开", "")
filelist_df$province <- str_replace(filelist_df$province, "将", "")
filelist_df$province <- str_replace(filelist_df$province, " ", "")

# round 2
table(filelist_df$province)
filelist_df$province <- str_replace(filelist_df$province, "\\(", "")
filelist_df$province <- str_replace(filelist_df$province, "国家", "")
filelist_df$province <- str_replace(filelist_df$province, "好", "")
filelist_df$province <- str_replace(filelist_df$province, "宁八省", "")
filelist_df$province <- str_replace(filelist_df$province, "展六省", "")
filelist_df$province <- str_replace(filelist_df$province, "川等省", "")
filelist_df$province <- str_replace(filelist_df$province, "市省", "")
filelist_df$province <- str_replace(filelist_df$province, "度安徽省", "安徽省 ")
filelist_df$province <- str_replace(filelist_df$province, "度省", "")
filelist_df$province <- str_replace(filelist_df$province, "强省", "")
filelist_df$province <- str_replace(filelist_df$province, "恢复省", "")
filelist_df$province <- str_replace(filelist_df$province, "息系统省", "")
filelist_df$province <- str_replace(filelist_df$province, "患者节省", "")
filelist_df$province <- str_replace(filelist_df$province, "意福建省", "")
filelist_df$province <- str_replace(filelist_df$province, "批六省", "")
filelist_df$province <- str_replace(filelist_df$province, "批和十省", "")
filelist_df$province <- str_replace(filelist_df$province, "批", "")
filelist_df$province <- str_replace(filelist_df$province, "抗癌药省", "")
filelist_df$province <- str_replace(filelist_df$province, "报送省", "")
filelist_df$province <- str_replace(filelist_df$province, "接", "")
filelist_df$province <- str_replace(filelist_df$province, "接省", "")
filelist_df$province <- str_replace(filelist_df$province, "整", "")
filelist_df$province <- str_replace(filelist_df$province, "新任副省", "")
filelist_df$province <- str_replace(filelist_df$province, "构接省", "")
filelist_df$province <- str_replace(filelist_df$province, "步解决省", "")
filelist_df$province <- str_replace(filelist_df$province, "浙浙江省", "浙江省")
filelist_df$province <- str_replace(filelist_df$province, "版", "")
filelist_df$province <- str_replace(filelist_df$province, "理", "")
filelist_df$province <- str_replace(filelist_df$province, "用", "")
filelist_df$province <- str_replace(filelist_df$province, "疗保险省", "")
filelist_df$province <- str_replace(filelist_df$province, "疗救助省", "")
filelist_df$province <- str_replace(filelist_df$province, "的", "")
filelist_df$province <- str_replace(filelist_df$province, "直及中省", "")
filelist_df$province <- str_replace(filelist_df$province, "确", "")
filelist_df$province <- str_replace(filelist_df$province, "^省$", "")
filelist_df$province <- str_replace(filelist_df$province, "第..省", "")
filelist_df$province <- str_replace(filelist_df$province, "算试点省", "")
filelist_df$province <- str_replace(filelist_df$province, "职工省", "")
filelist_df$province <- str_replace(filelist_df$province, "范", "")
filelist_df$province <- str_replace(filelist_df$province, "药物", "")
filelist_df$province <- str_replace(filelist_df$province, "补", "")
filelist_df$province <- str_replace(filelist_df$province, "西南五省", "")
filelist_df$province <- str_replace(filelist_df$province, "规范省", "")
filelist_df$province <- str_replace(filelist_df$province, "订", "")
filelist_df$province <- str_replace(filelist_df$province, "请", "")
filelist_df$province <- str_replace(filelist_df$province, "豫鄂四省", "")
filelist_df$province <- str_replace(filelist_df$province, "请", "")
filelist_df$province <- str_replace(filelist_df$province, "郴州市省", "")
filelist_df$province <- str_replace(filelist_df$province, "险公省", "")
filelist_df$province <- str_replace(filelist_df$province, "集采", "")
filelist_df$province <- str_replace(filelist_df$province, "面展省", "")
filelist_df$province <- str_replace(filelist_df$province, "项\\)", "")
filelist_df$province <- str_replace(filelist_df$province, " ", "")

## round 3
table(filelist_df$province)
filelist_df$province <- str_replace(filelist_df$province, "\\d省", "")
filelist_df$province <- str_replace(filelist_df$province, "郴州", "")
filelist_df$province <- str_replace(filelist_df$province, "第.省", "")
filelist_df$province <- str_replace(filelist_df$province, "等", "")
filelist_df$province <- str_replace(filelist_df$province, "规省", "")
filelist_df$province <- str_replace(filelist_df$province, "苏省", "")
filelist_df$province <- str_replace(filelist_df$province, "^江$", "江苏省")
filelist_df$province <- str_replace(filelist_df$province, "构省", "")
filelist_df$province <- str_replace(filelist_df$province, "清算省", "")

# 2.8 Index

# add a unique identifyer for each document
filelist_df$doc_index  <- NA
filelist_df$doc_index  <- seq.int(nrow(filelist_df))


# 2.9 clean text

# remove irrelevant elements like line breaks from the text
filelist_df$text_clean <- filelist_df$text_work%>%
  str_remove_all("\r") %>%
  str_remove_all("\n") %>%
  str_remove_all("/")
filelist_df$text_clean[1]


# 2.10 save the data

## remaining problems
# 1. some documents lack a date
# 2. date or document identifier may be misleading
# 3. more cleaning of provinces and cities is needed.

# as R data frame
save(filelist_df,
     file = "healthcare_docs_20230725.rda")

# as csv file
write.csv(filelist_df,
          file = "healthcare_docs_20231123.csv",
          row.names = F)


# for Access, we can drop information no longer needed to save space
filelist_slim <- filelist_df %>%
  select(-text, -text_work)


save(filelist_slim,
     file = "healthcare_slim_20230727.rda")

write.csv(filelist_slim,
          file = "healthcare_slim_20230725.csv",
          row.names = F)

