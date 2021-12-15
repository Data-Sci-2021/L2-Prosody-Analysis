---
title: "search_wav"
author: "Miroo Lee"
date: "12/14/2021"
output: 
  html_document:
    toc: true
    toc_float: true
---

```{r setup, include=FALSE}
library(tidyverse)
library(stringr)
library(readr)
library(ggplot2)
library(lme4)
library(lmerTest)
```

## Finding the right files
This document illustrates steps for finding specific audio files from PELIC_speech_compiled.csv. PELIC_speech_compiled.csv is from a private PELIC speech data set, which is not publicly available yet. You can contact Na-Rae Han(naraehan@pitt.edu) to inquire the access to the data.  

This document produces the following csv outputs:  
**1. 'korean_monologues_lv13.csv': list of wav files**  
**2. 'korean_monologues_lv13_transcriptions.csv': list of txt transcriptions of wav files**  

----------------------------------  

### 1.1 Read in the index file

```{r echo=TRUE, warning=FALSE}
folder <- "/Users/miroolee/Documents/DataScience/L2-Prosody-Analysis"
dat_path <- paste(folder, "/PELIC_speech_compiled.csv", sep="")
dat <- read_csv(dat_path) 
```

### 1.2 Filter by L1 and level
For this project, I looked for speech files of Korean speakers who were enrolled for three semesters(level 3 to 5). The code below shows Korean speakers who were enrolled for level 3-5 or more. The output data may include files from level 2 if speakers were enrolled for 2,3,4,and 5. But all speakers will have minimum of 3,4,5 level data. 
```{r}
kor_3levels <- dat %>%
  filter (L1=="Korean" & level_id!="2") %>% #excluding level 2
  distinct (anon_id, level_id) %>%
  count (anon_id) %>%
  filter (n==3) %>% # for each subject(anon_id), search if they have three semesters 
  inner_join (dat, by="anon_id") %>%
  rename(row_id = 3)
```

### 1.3 Filter by task type  
The different types of wav files are given specific numbers (file_info_id) based on the task type of the speaker. For my project, I looked for two-minute monologues, which has a file_info_id of 1. The detailed file_info_id can be found in PELIC_speech_corpus github repository which is private for the moment.   
```{r}
kor_dat <- kor_3levels %>%
  filter (level_id=="3"|level_id=="5") %>%
  filter (file_info_id=="1") 
print(kor_dat)

write.csv(kor_dat, 'KOR_mono.csv')
```

### 1.4 Find corresponding txt transcripts  
This actually created a dataframe with 33 variables. For this analysis, I did not make use of these text files as I annotated all speech files manually. But in future, these txt files will probably come in handy when we have to analyze more files, as we would not have to transcribe the files from sctrach. Note that the text files are transcribed by the students and therefore contain errors.  
```{r}
kor_txt <- kor_3levels %>%
  inner_join (kor_dat, by = c("row_id" = "corresponding_file")) %>%
  select(-ends_with("y"))
print(kor_txt)
write.csv(kor_txt, 'KOR_mono_scripts.csv')
```

