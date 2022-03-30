Progress report
================
Miroo Lee
10/12/2021


## 10-12-2021

Created the Github repo and uploaded the progress report and the plan docs. Set gitignore to R and license as MIT license.

## 10-12-2021

Updated project plan.

## 10-28-2021

Created wav folder where future audio files will be uploaded. Created a note that records data processing on PELIC\_speech\_compiled.csv which is a compilation of the PELIC speech data. Currently, the PELIC speech corpus nor PELIC speech compiled.csv is NOT available publicly online. For now, a portion of the corpus and the corresponding part of PELIC speech compiled.csv are made public in this repository under the permission of the PELIC data mining group. 

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
  7. Add [DIS] and create first syllable only data (firstSyll_data).  
  8. Add [DFL] and create final syllable only data (finSyll_data).  
  
[wordList.csv](wordList.csv)* is a handcoded csv file that contains list of words from textgrid files with the information of 1) syllable structure (CV, CVV, CVC, etc.) and 2) presence of lexical stress on each syllable in each word. The stress information is based on the CMU Pronouncing Dictionary (http://www.speech.cs.cmu.edu/cgi-bin/cmudict). I am hoping to generate a complete word list from CMU dictionary through computational method in future.    

- All monologue speech files of Korean speakers with three semesters are made available in the [wav](wav) folder. A portion of the speech files are annotated in textgrids mantually. These files are shared in [data_samples](data_samples) folder.  


## 3rd progress report  

- Started statistical analysis in 'Part 4. Statistical Analysis'. Separate analysis were made for Domain Initial Strengthening (DIS) and Domain Final Lengthening (DFL).   

## 4th progress report (03-30-2022)  

**1. Corrected range of prosodic gestures: from segement to syllable**  
Previously, the focus of analysis of the pause effects was conducted per each segment. For example, each segment was examined for its preceding pause duration. This results in situations like 'pause_level_2 # CV' where the consonant C is marked as having a  preceding pause level 2 but V is marked as having a preceding pause level 1. This was changed so that both C and V in #CV will be marked as preceded by pause level 2. 

**2. More annotation on the way**   
Additional speech files by female students are being annotated. The annotated files are saved in separate google drive and need a review. Based on the word-level annotation, Wordlist is being updated.  
