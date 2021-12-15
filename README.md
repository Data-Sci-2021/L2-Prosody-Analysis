## L2-Prosody-Analysis  
**Miroo Lee (mil136@pitt.edu) 12-13-2021 **  

1.Overview  
--------------------------------------------------------------   
This is Miroo Lee's project repo for Data Science (LING 2340). The goal of this project is to investigate how L2 learners' speech develop rhythmic properties of prosody by examining temporal modifications of phonetic segments as a function of lexical stress and domain-initial boundary lengthening.   

2.Dataset 
--------------------------------------------------------------   
The data set I started my project with comes from the PELIC speech corpus from the University of Pittsburgh. The PELIC speech corpus is a large learner corpus, and the current project examined 2-minute semi-spontaneous monologues by Korean students. You can find more information about the corpus from [here](https://eli-data-mining-group.github.io/Pitt-ELI-Corpus/).  

3.Contents 
--------------------------------------------------------------   
In addition to this README file, there are four folders and eleven other files.  

In the root folder:  
* [**`final_report.md`**](final_report.md) describes the results of the data analysis.  
* [`README.md`](README.md) is the current document you are reading.  
* [`LICENSE`](LICENSE) describes the licensing term for the project.  
* [`.gitignore`](.gitignore) has git ignored file entries.  
* [`project_plan.md`](project_plan.md) describes the initial plan for the project.  
* [`project_progress.md`](project_progress.md) shows three progress reports throughout the semester.  
* [`presentation.pdf`](presentation.pdf) is the slides of the presentation I gave at the end of the semester. This presentation only included the preliminary data analysis. More detailed results are documented in [`final_report.md`](final_report.md)   
* [`search_wav.Rmd`](search_wav.Rmd) contains codes for identifying wav file names by filtering L1, level, and task type.  
* [`search_wav.md`](search_wav.md) same as the above but in md file.    
* [`KOR_mono.csv`](KOR_mono.csv) is an output of [`search_wav.md`](search_wav.md). It is a list of two-minute monologue speech files of Korean speakers who were enrolled for three semesters.  
* [`KOR_mono_scripts.csv`](KOR_mono_scripts.csv) is another output of [`search_wav.md`](search_wav.md). It is a list of transcripts for the corresponding speech files.  
* [`export_from_three_tires.praat`](export_from_three_tiers.praat) is a Praat script that compiles annotated information from multiple praat textgrids to a single txt file.   
* [`wordList.csv`](wordList.csv) contains a list of words found in wav_SAMPLES. The list also contains syllable structure and lexical stress information of each word.  
* [`new_wordList.csv`](new_wordList.csv) contains a list of words found in three wav files from the speaker ea4.  
* [`data_analysis.Rmd`](data_analysis.Rmd) contains codes for data cleaning & analysis.  
* [`data_analysis.md`](data_analysis.md) same as the abobe but in md file.  
* [`plots`](plots) has plots from [`data_analysis.Rmd`](data_analysis.Rmd).  
* [`scratchpad`](scratchpad) has codes I tried and documented for my project.  
* [`wav`](wav) has 129 wav files identified on [`KOR_mono.csv`](KOR_mono.csv).  
* [`wav_SAMPLES`](wav_SAMPLES) has subset of wav files which are annotated in textgrid files from [`wav`](wav).  



