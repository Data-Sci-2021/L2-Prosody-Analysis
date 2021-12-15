L2 Prosody Analysis
================
Miroo Lee
10/12/21

### Goal
***
This project aims to investigate semi-spontaneous L2 speech in order to uncover how L2 speakers signal prosodic domains through phonetic modulations. It specifically focuses on providing illustrations of general scope of prosodic gestures in relations to durations of pauses at different proficiency levels. The main research questions are:  

1.	How are prosodic gestures realized in L2 speakers’ semi-spontaneous speech?   
2.	How are pause durations related to prosodic domain encodings?  
3.	How does the phonetic encoding of prosodic properties change as the L2 speakers’ proficiency level develops?  

As the current ToBI system does not account for L2 speakers' prosody which may not use the same pitch movement as native speakers to mark prosodic structures, pause duration is used as an approximate measure of different degrees of prosodic domain juncture. This allows for a way to examine how the final-lengthening and the initial-strengthening are realized in L2 speech.  


### Data
***
There will be two parts in the data; speech files and textgrid files.   

1. Speech Files  

I will use portions of speech files from The University of Pittsburgh English Language Corpus (PELIC)(<http://doi.org/10.5281/zenodo.3991977>). For the current project, I will focus on Korean speakers who enrolled in English class over three semesters. Speech files from their first vs. third semesters will be examined.

2. TextGrid Files  

I will try to use ASR and Montreal Forced Aligner (<https://montreal-forced-aligner.readthedocs.io/en/latest/>) for the basic annotation. Then I will fine-tune the annotation manually using Praat.

### Analysis
***
I will look at the following values of syllables that contain voiceless stop consonant in syllable onset position. 

1. VOT  
2. VOT%  
3. vowel duration  
4. preceding pause duration level (0 vs. 1 vs. 2 vs. 3) 

The coding scheme of pauses is as the following:  

 * 0 = silent pause shorter than 0.15 sec  
 * 1 = silent pause between 0.15 - 1 sec    
 * 2 = silent pause between 1 - 2 sec    
 * 3 = silent pause longer than 2 sec  

In addition to the above information, each syllable will be marked for the following information.  

1. word stressed vs. unstressed  
2. prosodic domain final vs. nonfinal syllable (precedes a pause level 1 or higher)  
3. prosodic domain initial vs. noninitial syllable (follows a pause level 1 or higher)  

Two sets of data will be created for separate analysis of Domain Final Lengthening and Domain Initial Strengthening effects. The first set of data comprise vowel durations and VOT% in domain final and non-final syllables. The second set of data include vowel durations and VOT% in domain-initial and non-initial syllables.  
