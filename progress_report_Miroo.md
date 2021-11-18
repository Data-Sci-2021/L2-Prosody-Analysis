Progress report
================
Miroo Lee
10/12/2021


## 10-12-2021

Created the Github repo and uploaded the progress report and the plan docs. Set gitignore to R and license as MIT license.

## 10-12-2021

Updated project plan.

## 10-28-2021

Created wav folder where future audio files will be uploaded. Created a note that records data processing on PELIC\_speech\_compiled.csv which is a compilation of the PELIC speech data. Currently, the PELIC speech corpus nor PELIC speech compiled.csv is available publicly. But a portion of the corpus and the corresponding part of PELIC speech compiled.csv are made public in this repository under the permission of the PELIC data mining group. 

## 1st progress report

- Started ['data_processing_note.Rmd'](data_processing_note.Rmd).  

- Documented the process to identify Korean speakers' monologue speech files from PELIC\_speech\_compiled.csv. You can find the relevant codes on "Part 1. Processing PELIC_speech_compiled.csv". The following steps were involved:    
  1. Identified Korean speakers with minimum enrollment of 3-5 levels (KS_lv13) and their 2-minute monologues; this was saved as ['korean_monologues_lv13.csv'](korean_monologues_lv13.csv).  
  2. Based on ['korean_monologues_lv13.csv'](korean_monologues_lv13.csv), hand-moved all the corresponding speech files to ['wav'](wav/) folder.   
  3. Based on ['korean_monologues_lv13.csv'](korean_monologues_lv13.csv), identified the transcriptions for KS_lv13 speech files. Saved the transcriptions as ['korean_monologues_lv13_trnascription.csv'](korean_monologues_lv13_transcriptions.csv). The future plan is to use these transcriptions for Montreal Forced Aligner to generate TextGrids. 

## 11-4-2021

Added [data_samples](data_samples) folder containing one wav file and one textgrid.

## 11-8-2021

Tried MFA, but the program threw errors and did not generate textgrids. 

## 11-9-2021

Added all the annotated wav and textgrids so far to [data_samples](data_samples).  
Uploaded praat script [export_from_three_tiers.praat](export_from_three_tiers.praat) that reads annotated intervals from three tiers from a textgrid.  

## 2nd progress report  

Updated ['data_processing_note.Rmd'](data_processing_note.Rmd) for the following parts.  

- Documented the process of reading textgrids into a csv file in 'Part 2. Read textgrids'. The process requires a praat script [export_from_three_tiers.praat](export_from_three_tiers.praat).  

- Documented the process of cleaning the praat script output in 'Part 3. Clean the praat output'. The process involves the following steps.
  1. Identify which encoding we need using guess_encoding function form readr package.  
  2. Add proficiency level information from PELIC csv to praat output.   
  3. Add syllable label and word label information from the previous [wordList.csv](wordList.csv)* document.
  4. Add [SyllOrder] (wd initial,,medial,final) for each syllable. Add [stress] (stressed/unstressed).  
  5. Add [normedPhoneDur] which will be used specifically for VOT to account for speech rate.  
  6. Remove numbers from [PrecedingPhone], [PhoneLabel], [FollowingPhone].  
  7. Add [DIS] and create firstSyll data.  
  8. Add [DFL] and create finSyll data.  
  
[wordList.csv](wordList.csv)* file is handcoded. This file contains primary and secondary stress information as well as syllable structure (ex. CV, CCV) based on CMU word bank. I am hoping to automate this process using CMU word bank dictionary in future, so that lexical stress and syllable structure of words are available for all the words without handcoding them.  

- Started statistical analysis in 'Part 4. Statistical Analysis'. Separate analysis were made for Domain Initial Strengthening (DIS) and Domain Final Lengthening (DFL).   

- All monologue speech files for Korean speakers with three semesters are made available in [wav](wav) folder. A portion of them annotated with textgrids and shared in [data_samples](data_samples) folder.  





