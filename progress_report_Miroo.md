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
  3. Identified the transcriptions for KS_lv13 speech files. Saved the transcriptions as ['korean_monologues_lv13_trnascription.csv'](korean_monologues_lv13_transcriptions.csv). The future plan is to use these transcriptions for Montreal Forced Aligner to generate TextGrids. 

## 11-4-2021

Added [data_samples](data_samples) folder containing one wav file and one textgrid.

## 11-8-2021

Tried MFA, but the program threw errors and did not generate textgrids. 

## 11-9-2021

Added all the annotated wav and textgrids so far to [data_samples](data_samples).  
Uploaded praat script 

## 2nd progress report  


