Progress report
================
Miroo Lee
10/12/2021

`{r setup, include=FALSE} knitr::opts_chunk$set(echo = TRUE)`

## 10-12-2021

Created the Github repo and uploaded the progress report and the plan docs. Set gitignore to R and license as MIT license.

## 10-12-2021

Updated project plan.

## 10-28-2021

Created wav folder where future audio files will be uploaded. Created a note that records data processing on PELIC\_speech\_compiled.csv which is a compilation of the PELIC speech data. Currently, PELIC speech data nor PELIC\_speech\_compiled.csv is available for public access. However, I got a permission to publish subset of the PELIC speech data (and corresponding file information)

## 1st progress report

Completed data processing note on PELIC\_speech\_compiled.csv, illustrating the following steps I took to for this project.  
1. identify korean speakers who enrolled minimum of 3-5 levels  
2. identify 2-minute monologues based on file\_info\_id.  
3. add the identified files' information as ['korean_monologues_lv13.csv'](korean_monologues_lv13.csv).  
4. add corresponding wav files to L2-prosody-Analysis ['wav'](wav/) folder.  
5. identify transcriptions for the corresponding audio files.  
6. add the identified transcription information as ['korean_monologues_lv13_trnascription.csv'](korean_monologues_lv13_transcriptions.csv).

Now the full speech data are available in wav folder.
