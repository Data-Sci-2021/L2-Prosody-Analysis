---
title: "data_analysis"
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

## Part 1. Cleaning the praat output  
After running a praat script that exports annotated information from Praat text grids, we get a txt file that needs cleaning. This document illustrates how I cleaned and prepared the data for the analysis.    

----------------------------------   

### 1. Determine the encoding   
I used a very handy guess_encoding function form readr package.  

```{r echo=TRUE, warning=FALSE}
wav_folder <- "/Users/miroolee/Documents/DataScience/L2-Prosody-Analysis/wav_SAMPLES"
dat_path <- paste(wav_folder, "/duration_results.txt", sep="")
guess_encoding(dat_path)
dat <- read_tsv(dat_path, locale=locale(encoding="UTF-16"))
```


### 2. Add proficiency level  
I united some parts from the previous PELIC output (1.3) to praat output 
```{r}
folder <- "/Users/miroolee/Documents/DataScience/L2-Prosody-Analysis"
lev_path <- paste(folder, "/KOR_mono.csv", sep="")
lev <- read.csv(lev_path)

lev1<-lev %>%
  unite(Filename, c("row_id", "anon_id")) %>%
  select (c(Filename, gender, level_id))

dat1 <- dat %>%
  left_join(lev1, dat, by="Filename")
```

### 3. Add list of words and their lexical stress info  
For this part, I made a separate document containing syllable structure and lexical stress information of all the words in the wav files [`wordList.csv`](wordList.csv) which can be found in my github repository. This information was handcoded by me, and therefore needs to be updated continuously as you add more wav files with new words. Obviously this is not optimal, and I hope to replace this document with some sort of dictionary later that contains syllable structure and stress information. 

Here I have three newly annotated wav files. I am combining the new words to my previous 'wordList.csv' file. 
```{r}
wdDat_path <- paste(folder, "/wordList.csv", sep="")
wdDat <- read.csv(wdDat_path)

dat2 <- dat1 %>%
  left_join(wdDat, by =c("SyllLabel" = "SyllLabel", "WordLabel" = "WordLabel"))

new_wdDat <- dat2 %>%
  filter(Filename=="21819_ea4"|Filename=="23027_ea4"|Filename=="24473_ea4") %>%
  distinct(WordLabel,SyllLabel, .keep_all=TRUE) #I think I can also use anti_join() but oh well.

write.csv(new_wdDat, 'new_wordList.csv')
```

Next step is to work on new_wordList.csv that does not have values in SyllCV, primary and secondary stress. This is the part that needs handcoding (until I figure out how to replace it with dictionary). For now, I will work with dat2.  


### 4. Specify syllables' positions in words and mark if stressed    
I added two new variables:  
__[SyllOrder]__ has with 3 levels: (wd) initial, medial and final.   
__[stress]__ has 2 levels: stressed, unstressed.   

There's an issue in the PrimaryStress coding. Now if syllable 1,2,3 are stressed (ex:USA), PrimaryStress value shows as 123. This would be shown as 'unstressed' in stress column. The number of this exception is not great, and we will move forward with the data as it is for now.  

```{r}
 dat3<-dat2 %>%
  select(-c(PitchMaxInPhone,...13)) %>%
  separate(SyllLabel, into = c("currentSyll", "entireSyll", sep ="_" )) %>%
  add_column(SyllOrder = "medial") %>%
  mutate (SyllOrder = case_when(
  currentSyll == "1" ~ "initial",
  currentSyll == entireSyll ~ "final",
  currentSyll < entireSyll ~ "medial")) %>%
  mutate (stress = case_when(
    currentSyll == PrimaryStress ~ "stressed",
    currentSyll != PrimaryStress ~ "unstressed"))
```

### 5. Normalize segment durations    
I added one new variable:
__[normedPhoneDur]__ which is calculated by dividing raw duration by the syllable duration. This was used specifically for voiceless stops VOT and voiceless fricatives to account for speech rate.  
```{r}
dat4 <- dat3 %>%
  mutate(normedPhoneDur = PhoneDuration/SyllDuration )
```

### 6. Clean the phone labels     
Remove numbers from [PrecedingPhone].[PhoneLabel].[FollowingPhone].  
```{r}
 dat5 <- dat4 %>% 
  mutate_at("PrecedingPhone", str_replace, "[12345]_", "") %>%
  mutate_at("PhoneLabel", str_replace, "[12345]_", "") %>%
  mutate_at("FollowingPhone", str_replace, "[12345]_", "")
```

### 7. Get word-initial syllables for DIS  
In this process, I am going to separate **word-initial syllables** for the analysis of **DIS (Domain Initial Strengthening)** effect. Similarly, I am separating **word-final syllables** for the analysis of **DFL (Domain Fianl Lengthening)** effect.  

Note that DIS is operationalized as preceding pause durations as a proxy measure for the strength of prosodic domain junctures. I assumes longer the pause is, higher the prosodic domain is. I expect stronger DIS for longer pause.  


Here, I select **word-initial syllables**, and then assign preceding pause level for each word-initial syllable using a new variable [DIS]. All the word-initial syllables are saved as **'firstSyll_dat'**.
```{r}
firstSyll_dat <- dat5 %>%
  group_by(WordLabel,SyllDuration) %>%
  filter(currentSyll==1)%>%
  mutate(DIS = case_when(
    PrecedingPhone == "L" ~ "3",
    PrecedingPhone == "M" ~ "2",
    PrecedingPhone == "S" ~ "1")) %>%
  fill(DIS, .direction="down") %>%
  replace_na(list(DIS = 0)) %>%
  mutate(SyllCV=factor(SyllCV))
```

### 8. Get word-final syllables for DFL  
Here, I select **word-final syllables** and assign following pause level for each word-final syllable using a new variable [DFL], short for _domain_final_lengthening_. All the word-beignning syllables are saved as a separate dataframe named **'finSyll_dat'**. 
```{r}
finSyll_dat <- dat5 %>%
  group_by(WordLabel,SyllDuration) %>%
  filter(currentSyll == entireSyll) %>%
  mutate(DFL = case_when(
    FollowingPhone == "L" ~ "3",
    FollowingPhone == "M" ~ "2",
    FollowingPhone == "S" ~ "1")) %>%
  fill(DFL, .direction="up") %>%
   replace_na(list(DFL = 0)) %>%
    mutate(SyllCV=factor(SyllCV))
```

### 9. Get CVC+CV syllable data 
I made a subset of dataset of with the two most frequent syllable structures, CV and CVC. Note that the main interests in this analysis is any durational changes in vowels and voiceless consonants as a function of stress, preceding/following pause, and proficiency level.  

Because VOT durations are differentially enhanced depending on a voicing feature(shorter for voiced, longer for voiceless), I only look at voiceless consonants. For the similar reason, I only look at single consonant onset, rather than looking at tauto syllabic onset (ex: steam).   

```{r}
summary(firstSyll_dat$SyllCV)
summary(finSyll_dat$SyllCV)
```


Word_initial and word_final datasets are separately analyzed. Four output datasets are made:  
**both_ini_V** : vowels in word_initial syllable CVC+CV    
**both_ini_C**: voiceless stops and fricatives in word_initial syllable CVC+CV  
**both_fin_V**: vowels in word_final syllable CVC+CV  
**both_fin_C**: voiceless stops and fricatives in word_final syllable CVC+CV   
```{r}
both_dat_ini <- firstSyll_dat %>% 
  filter(SyllCV %in% c("CVC","CV")) %>%
    filter(PhoneLabel %in% c("t_vot","k_vot","p_vot","f","s","ð","ʃ","V")) %>%
    mutate(DIS=factor(DIS)) %>%
    mutate(DIS=fct_relevel(DIS,c("0","1","2","3"))) %>%
    mutate(stress=factor(stress))%>%
    mutate(stress=fct_relevel(stress,c("unstressed","stressed"))) %>%
    mutate(level_id=factor(level_id))%>%
    drop_na(level_id)

both_ini_V <- both_dat_ini %>%
  filter(PhoneLabel %in% c("V"))
both_ini_C <- both_dat_ini %>%
  filter(PhoneLabel %in% c("t_vot","k_vot","p_vot","f","s","ð","ʃ"))

both_dat_fin <- finSyll_dat %>% 
  filter(SyllCV %in% c("CVC","CV")) %>%
    filter(PhoneLabel %in% c("t_vot","k_vot","p_vot","f","s","ð","ʃ","V")) %>%
   mutate(DFL=factor(DFL)) %>%
    mutate(DFL=fct_relevel(DFL,c("0","1","2","3"))) %>%
    mutate(stress=factor(stress))%>%
    mutate(stress=fct_relevel(stress,c("unstressed","stressed"))) %>%
    mutate(level_id=factor(level_id))%>%
    drop_na(level_id)

both_fin_V <- both_dat_fin %>%
  filter(PhoneLabel %in% c("V"))
both_fin_C <- both_dat_fin %>%
  filter(PhoneLabel %in% c("t_vot","k_vot","p_vot","f","s","ð","ʃ"))
```

## Part 2. Statistical Analysis on DIS on CV
I tested how the word-initial syllable's consonants(C)' and vowels(V)' durations are affected by the preceding __1.pause duration(0-3)__, the presence of __2.lexical stress(str vs unstr)__, and the learners' __3.proficiency level(3 vs.5)__. As for the dependent variable, **log([PhoneDuration])** was used for vowels and **[normedPhonDur]** for consonants.

### w/o interaction; V in wd-initial   
```{r}
lm1 = lmer(log(PhoneDuration)~DIS+stress+level_id+(1|WordLabel)+(1|Filename), data=both_ini_V)
summary(lm1) # DIS decreases V while stress increases V.
ggplot(both_ini_V,
       aes(as.factor(DIS),log(PhoneDuration), color=stress))+
  geom_boxplot(outlier.shape=NA)+
  xlab('Boundary Degree 0<1<2<3')+
  ggtitle("V at word_initial")
```

### w/o interaction; C in wd-initial   

```{r}
lm2 = lmer(normedPhoneDur~DIS+stress+level_id+(1|WordLabel)+(1|Filename), data=both_ini_C)
lm2.2 = lmer(normedPhoneDur~DIS+stress+level_id+(1|WordLabel)+(1|Filename)+(1|PhoneLabel), data=both_ini_C)
anova(lm2,lm2.2) # The model that accounts for different phone types is better (lm2.2)
summary(lm2.2) # DIS increases C ratio while stress decreases C ratio.
ggplot(both_ini_C,
       aes(as.factor(DIS),normedPhoneDur, color=stress))+
  geom_boxplot(outlier.shape=NA)+
  xlab('Boundary Degree 0<1<2<3')+
  ggtitle("C at word_initial")
```

-----------------------------  

### w/ interaction; V in wd-initial
For the analysis, I am interested in how proficiency level interact with stress and boundary effects.   
```{r}
lm3 = lmer(log(PhoneDuration)~DIS*stress*level_id+(1|WordLabel)+(1|Filename), data=both_ini_V)
summary(lm3) # V was lengthened by stress.
ggplot(both_ini_V, aes(as.factor(DIS),log(PhoneDuration), color=stress))+
  geom_boxplot(outlier.shape=NA)+
  xlab('Boundary Degree 0<1<2<3')+
  ggtitle("V at word_initial in 1st vs. 3rd semester")+
  facet_wrap(~level_id,labeller=label_both)
```
  
### w/ interaction; C in wd-initial  
```{r}
lm4 = lmer(normedPhoneDur~DIS*stress*level_id+(1|WordLabel)+(1|Filename), data=both_ini_C)
lm5 = lmer(normedPhoneDur~DIS*stress*level_id+(1|WordLabel)+(1|Filename)+(1|PhoneLabel), data=both_ini_C)
anova(lm4, lm5) # including PhoneLabel in random intercept made the model better
summary(lm5) # C ratio was reduced when stressed.However, this effect disappeared when a syllable follows a pause greater than 1s. In the third semester, C ratio was reduced when the syllable follows a pause greater than 2s.
ggplot(both_ini_C,
       aes(as.factor(DIS),normedPhoneDur, color=stress))+
  geom_boxplot(outlier.shape=NA)+
 # stat_summary(fun.data=mean_cl_boot)+
  xlab('Boundary Degree 0<1<2<3')+
  ggtitle("C at word_initial in 1st vs. 3rd semester")+
  facet_wrap(~level_id,labeller=label_both)
```

