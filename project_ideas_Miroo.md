---
title: "L2 Prosody Analysis"
author: "Miroo Lee"
date: "10/12/2021"
output: github_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```


## Goal  
  
This project looks at speech files of Korean students in English language class over three semesters, focusing on the patterns of temporal modifications of phonetic segments before and after pauses.  

## Data  
There will be two parts in the data; speech files and textgrid files.  
*Speech Files  
I will use a portion of speech files from The University of Pittsburgh English Language Corpus (PELIC) (http://doi.org/10.5281/zenodo.3991977). For the current project, I will focus on Korean speakers who enrolled in English class over three semesters. Speech files from their first vs. third semesters will be examined.  

*TextGrid Files  
I will try to use ASR and Montreal Forced Aligner (https://montreal-forced-aligner.readthedocs.io/en/latest/) for the basic annotation. Then I will fine-tune the annotation manually using Praat.    

## Analysis   
I would need segment-level annotation to do any meaningful analysis on L2 prosody. One analysis I've done for my comps - and something I would like to build upon is to examine VOT, VOT%, and vowel duration of syllables that contain voiceless stop consonants and see if the values systematically change as a function of the preceding pause durations. I would like to test if different levels of pause durations can be taken as approximate measure of different degrees of prosodic domain juncture. If this hypothesis can be confirmed, then I can examine how L2 learners' prosody development without having to rely on ToBI system. 
