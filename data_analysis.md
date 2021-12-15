data_analysis
================
Miroo Lee
12/14/2021

-   [Part 1. Cleaning the praat
    output](#part-1-cleaning-the-praat-output)
    -   [1. Determine the encoding](#1-determine-the-encoding)
    -   [2. Add proficiency level](#2-add-proficiency-level)
    -   [3. Add list of words and their lexical stress
        info](#3-add-list-of-words-and-their-lexical-stress-info)
    -   [4. Specify syllables’ positions in words and mark if
        stressed](#4-specify-syllables-positions-in-words-and-mark-if-stressed)
    -   [5. Normalize segment durations](#5-normalize-segment-durations)
    -   [6. Clean the phone labels](#6-clean-the-phone-labels)
    -   [7. Get word-initial syllables for
        DIS](#7-get-word-initial-syllables-for-dis)
    -   [8. Get word-final syllables for
        DFL](#8-get-word-final-syllables-for-dfl)
    -   [9. Get CVC+CV syllable data](#9-get-cvccv-syllable-data)
-   [Part 2. Statistical Analysis on DIS on
    CV](#part-2-statistical-analysis-on-dis-on-cv)
    -   [w/o interaction; V in
        wd-initial](#wo-interaction-v-in-wd-initial)
    -   [w/o interaction; C in
        wd-initial](#wo-interaction-c-in-wd-initial)
    -   [w/ interaction; V in
        wd-initial](#w-interaction-v-in-wd-initial)
    -   [w/ interaction; C in
        wd-initial](#w-interaction-c-in-wd-initial)

## Part 1. Cleaning the praat output

After running a praat script that exports annotated information from
Praat text grids, we get a txt file that needs cleaning. This document
illustrates how I cleaned and prepared the data for the analysis.

------------------------------------------------------------------------

### 1. Determine the encoding

I used a very handy guess_encoding function form readr package.

``` r
wav_folder <- "/Users/miroolee/Documents/DataScience/L2-Prosody-Analysis/wav_SAMPLES"
dat_path <- paste(wav_folder, "/duration_results.txt", sep="")
guess_encoding(dat_path)
```

    ## # A tibble: 3 × 2
    ##   encoding     confidence
    ##   <chr>             <dbl>
    ## 1 UTF-16BE           1   
    ## 2 windows-1250       0.39
    ## 3 windows-1252       0.35

``` r
dat <- read_tsv(dat_path, locale=locale(encoding="UTF-16"))
```

    ## New names:
    ## * `` -> ...13

    ## Rows: 9333 Columns: 13

    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: "\t"
    ## chr (8): Filename, PrecedingPhone, PhoneLabel, FollowingPhone, PitchMaxInPho...
    ## dbl (4): StartingPoint, PhoneDuration, SyllDuration, WordDuration
    ## lgl (1): ...13

    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

### 2. Add proficiency level

I united some parts from the previous PELIC output (1.3) to praat output

``` r
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

For this part, I made a separate document containing syllable structure
and lexical stress information of all the words in the wav files
[`wordList.csv`](wordList.csv) which can be found in my github
repository. This information was handcoded by me, and therefore needs to
be updated continuously as you add more wav files with new words.
Obviously this is not optimal, and I hope to replace this document with
some sort of dictionary later that contains syllable structure and
stress information.

Here I have three newly annotated wav files. I am combining the new
words to my previous ‘wordList.csv’ file.

``` r
wdDat_path <- paste(folder, "/wordList.csv", sep="")
wdDat <- read.csv(wdDat_path)

dat2 <- dat1 %>%
  left_join(wdDat, by =c("SyllLabel" = "SyllLabel", "WordLabel" = "WordLabel"))

new_wdDat <- dat2 %>%
  filter(Filename=="21819_ea4"|Filename=="23027_ea4"|Filename=="24473_ea4") %>%
  distinct(WordLabel,SyllLabel, .keep_all=TRUE) #I think I can also use anti_join() but oh well.

write.csv(new_wdDat, 'new_wordList.csv')
```

Next step is to work on new_wordList.csv that does not have values in
SyllCV, primary and secondary stress. This is the part that needs
handcoding (until I figure out how to replace it with dictionary). For
now, I will work with dat2.

### 4. Specify syllables’ positions in words and mark if stressed

I added two new variables:  
**\[SyllOrder\]** has with 3 levels: (wd) initial, medial and final.  
**\[stress\]** has 2 levels: stressed, unstressed.

There’s an issue in the PrimaryStress coding. Now if syllable 1,2,3 are
stressed (ex:USA), PrimaryStress value shows as 123. This would be shown
as ‘unstressed’ in stress column. The number of this exception is not
great, and we will move forward with the data as it is for now.

``` r
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

    ## Warning: Expected 3 pieces. Additional pieces discarded in 1 rows [1].

    ## Warning: Expected 3 pieces. Missing pieces filled with `NA` in 9332 rows [2, 3,
    ## 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, ...].

### 5. Normalize segment durations

I added one new variable: **\[normedPhoneDur\]** which is calculated by
dividing raw duration by the syllable duration. This was used
specifically for voiceless stops VOT and voiceless fricatives to account
for speech rate.

``` r
dat4 <- dat3 %>%
  mutate(normedPhoneDur = PhoneDuration/SyllDuration )
```

### 6. Clean the phone labels

Removed numbers from
\[PrecedingPhone\].\[PhoneLabel\].\[FollowingPhone\].

``` r
 dat5 <- dat4 %>% 
  mutate_at("PrecedingPhone", str_replace, "[12345]_", "") %>%
  mutate_at("PhoneLabel", str_replace, "[12345]_", "") %>%
  mutate_at("FollowingPhone", str_replace, "[12345]_", "")
```

### 7. Get word-initial syllables for DIS

In this process, I separated **word-initial syllables** for the analysis
of **DIS (Domain Initial Strengthening)** effect. Similarly, I separated
**word-final syllables** for the analysis of **DFL (Domain Fianl
Lengthening)** effect.

Note that DIS is operationalized as preceding pause duration as a proxy
measure for the strength of prosodic domain junctures. I assumes longer
the pause is, higher the prosodic domain is. I expect stronger DIS for
longer pause.

I selected **word-initial syllables**, and then assigned preceding pause
level for each word-initial syllable using a new variable \[DIS\]. All
the word-initial syllables were saved as **‘firstSyll_dat’**.

``` r
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

I selected **word-final syllables** and assigned following pause level
for each word-final syllable using a new variable \[DFL\], short for
*domain_final_lengthening*. All the word-beignning syllables were saved
as a separate dataframe named **‘finSyll_dat’**.

``` r
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

I made a subset of dataset of with the two most frequent syllable
structures, CV and CVC. Note that the main interests in this analysis is
any durational changes in vowels and voiceless consonants as a function
of stress, preceding/following pause, and proficiency level.

Because VOT durations are differentially enhanced depending on a voicing
feature(shorter for voiced, longer for voiceless), I only looked at
voiceless consonants. For the similar reason, I only looked at single
consonant onset, rather than looking at syllable onset with double or
more consonants (ex: steam).

``` r
summary(firstSyll_dat$SyllCV)
```

    ##      V     VC     CV    VCC    CVV   CVCC    CCV    CVC   CVVC  CVVCC CVVCCC 
    ##     87    598   1142    255    267    571     66   1523    225     41     12 
    ##   CCVC  CCVCC  CVCCC   CCVV     VV    VVC  CCVVC  CCCVC  CVCCV   NA's 
    ##    107     78     22      2    144     23     45      6      3   1168

``` r
summary(finSyll_dat$SyllCV)
```

    ##      V    CVC   CVVC   CCVC     CV     VC   CVCC    VCC    CVV  CCVCC  CVVCC 
    ##     41   1954    333    124    941    524    909    255    189     73     60 
    ## CVVCCC    CCV  CVCCC    VCV   CCVV     VV    VVC  CCVVC  CCCVC  CVCCV   NA's 
    ##     12     41     34      9      2    148     25     45      6      3   1759

Word_initial and word_final datasets were separately analyzed. Four
output datasets are made:  
**both_ini_V** : vowels in word_initial syllable CVC+CV  
**both_ini_C**: voiceless stops and fricatives in word_initial syllable
CVC+CV  
**both_fin_V**: vowels in word_final syllable CVC+CV  
**both_fin_C**: voiceless stops and fricatives in word_final syllable
CVC+CV

``` r
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

I tested how the word-initial syllable’s consonants(C)’ and vowels(V)’
durations are affected by the preceding **1.pause duration(0-3)**, the
presence of **2.lexical stress(str vs unstr)**, and the learners’
**3.proficiency level(3 vs.5)**. As for the dependent variable,
**log(\[PhoneDuration\])** was used for vowels and **\[normedPhonDur\]**
for consonants.

### w/o interaction; V in wd-initial

``` r
lm1 = lmer(log(PhoneDuration)~DIS+stress+level_id+(1|WordLabel)+(1|Filename), data=both_ini_V)
summary(lm1) # DIS decreases V while stress increases V.
```

    ## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
    ## lmerModLmerTest]
    ## Formula: log(PhoneDuration) ~ DIS + stress + level_id + (1 | WordLabel) +  
    ##     (1 | Filename)
    ##    Data: both_ini_V
    ## 
    ## REML criterion at convergence: 838.7
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -3.3814 -0.4827 -0.0184  0.4708  3.4141 
    ## 
    ## Random effects:
    ##  Groups    Name        Variance Std.Dev.
    ##  WordLabel (Intercept) 0.250688 0.5007  
    ##  Filename  (Intercept) 0.009234 0.0961  
    ##  Residual              0.170791 0.4133  
    ## Number of obs: 546, groups:  WordLabel, 159; Filename, 12
    ## 
    ## Fixed effects:
    ##                 Estimate Std. Error        df t value Pr(>|t|)    
    ## (Intercept)     -2.44964    0.11926 149.48769 -20.541  < 2e-16 ***
    ## DIS1            -0.04801    0.04865 478.58898  -0.987   0.3242    
    ## DIS2            -0.13706    0.07670 449.44454  -1.787   0.0746 .  
    ## DIS3             0.10055    0.10556 488.73431   0.953   0.3413    
    ## stressstressed   0.51146    0.12356 160.13835   4.139 5.61e-05 ***
    ## level_id5       -0.07280    0.07902   7.95989  -0.921   0.3840    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##             (Intr) DIS1   DIS2   DIS3   strsss
    ## DIS1        -0.137                            
    ## DIS2        -0.064  0.256                     
    ## DIS3        -0.093  0.197  0.128              
    ## strssstrssd -0.854  0.009 -0.008  0.041       
    ## level_id5   -0.191 -0.006 -0.006 -0.029  0.000

``` r
ggplot(both_ini_V,
       aes(as.factor(DIS),log(PhoneDuration), color=stress))+
  geom_boxplot(outlier.shape=NA)+
  xlab('Boundary Degree 0<1<2<3')+
  ggtitle("V at word_initial")
```

![](/Users/miroolee/Documents/DataScience/L2-Prosody-Analysis/plotsunnamed-chunk-11-1.png)<!-- -->

### w/o interaction; C in wd-initial

``` r
lm2 = lmer(normedPhoneDur~DIS+stress+level_id+(1|WordLabel)+(1|Filename), data=both_ini_C)
lm2.2 = lmer(normedPhoneDur~DIS+stress+level_id+(1|WordLabel)+(1|Filename)+(1|PhoneLabel), data=both_ini_C)
anova(lm2,lm2.2) # The model that accounts for different phone types is better (lm2.2)
```

    ## refitting model(s) with ML (instead of REML)

    ## Data: both_ini_C
    ## Models:
    ## lm2: normedPhoneDur ~ DIS + stress + level_id + (1 | WordLabel) + (1 | Filename)
    ## lm2.2: normedPhoneDur ~ DIS + stress + level_id + (1 | WordLabel) + (1 | Filename) + (1 | PhoneLabel)
    ##       npar     AIC     BIC logLik deviance  Chisq Df Pr(>Chisq)    
    ## lm2      9 -394.69 -358.84 206.35  -412.69                         
    ## lm2.2   10 -480.42 -440.58 250.21  -500.42 87.731  1  < 2.2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

``` r
summary(lm2.2) # DIS increases C ratio while stress decreases C ratio.
```

    ## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
    ## lmerModLmerTest]
    ## Formula: normedPhoneDur ~ DIS + stress + level_id + (1 | WordLabel) +  
    ##     (1 | Filename) + (1 | PhoneLabel)
    ##    Data: both_ini_C
    ## 
    ## REML criterion at convergence: -468.9
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -2.9949 -0.5075 -0.0767  0.5218  5.1031 
    ## 
    ## Random effects:
    ##  Groups     Name        Variance Std.Dev.
    ##  WordLabel  (Intercept) 0.007051 0.08397 
    ##  Filename   (Intercept) 0.002982 0.05461 
    ##  PhoneLabel (Intercept) 0.020076 0.14169 
    ##  Residual               0.011815 0.10870 
    ## Number of obs: 397, groups:  WordLabel, 105; Filename, 12; PhoneLabel, 7
    ## 
    ## Fixed effects:
    ##                 Estimate Std. Error        df t value Pr(>|t|)    
    ## (Intercept)      0.40282    0.06285   9.88828   6.409 8.14e-05 ***
    ## DIS1             0.02439    0.01461 354.87006   1.669 0.096008 .  
    ## DIS2             0.04825    0.02392 344.75368   2.017 0.044494 *  
    ## DIS3             0.02374    0.02963 367.33844   0.801 0.423436    
    ## stressstressed  -0.11121    0.02873  91.95576  -3.870 0.000203 ***
    ## level_id5        0.03881    0.03897   8.59448   0.996 0.346496    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##             (Intr) DIS1   DIS2   DIS3   strsss
    ## DIS1        -0.054                            
    ## DIS2        -0.029  0.273                     
    ## DIS3        -0.062  0.183  0.131              
    ## strssstrssd -0.371 -0.023 -0.005  0.080       
    ## level_id5   -0.158 -0.001 -0.016 -0.005 -0.016

``` r
ggplot(both_ini_C,
       aes(as.factor(DIS),normedPhoneDur, color=stress))+
  geom_boxplot(outlier.shape=NA)+
  xlab('Boundary Degree 0<1<2<3')+
  ggtitle("C at word_initial")
```

![](/Users/miroolee/Documents/DataScience/L2-Prosody-Analysis/plotsunnamed-chunk-12-1.png)<!-- -->

------------------------------------------------------------------------

### w/ interaction; V in wd-initial

For the analysis, I am interested in how proficiency level interact with
stress and boundary effects. Therefore, I included interactions between
predictors in the model.

``` r
lm3 = lmer(log(PhoneDuration)~DIS*stress*level_id+(1|WordLabel)+(1|Filename), data=both_ini_V)
summary(lm3) # V was lengthened by stress.
```

    ## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
    ## lmerModLmerTest]
    ## Formula: log(PhoneDuration) ~ DIS * stress * level_id + (1 | WordLabel) +  
    ##     (1 | Filename)
    ##    Data: both_ini_V
    ## 
    ## REML criterion at convergence: 845.6
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -3.4140 -0.4584 -0.0265  0.4773  3.1293 
    ## 
    ## Random effects:
    ##  Groups    Name        Variance Std.Dev.
    ##  WordLabel (Intercept) 0.249201 0.49920 
    ##  Filename  (Intercept) 0.009455 0.09723 
    ##  Residual              0.172083 0.41483 
    ## Number of obs: 546, groups:  WordLabel, 159; Filename, 12
    ## 
    ## Fixed effects:
    ##                                Estimate Std. Error        df t value Pr(>|t|)
    ## (Intercept)                    -2.40613    0.13567 221.62259 -17.734  < 2e-16
    ## DIS1                           -0.18671    0.13296 475.63407  -1.404  0.16091
    ## DIS2                           -0.01875    0.34091 446.07475  -0.055  0.95618
    ## DIS3                           -0.05687    0.18297 443.63131  -0.311  0.75607
    ## stressstressed                  0.47092    0.14437 254.69596   3.262  0.00126
    ## level_id5                      -0.12560    0.14548  80.82336  -0.863  0.39049
    ## DIS1:stressstressed             0.15548    0.14773 469.26282   1.052  0.29312
    ## DIS2:stressstressed            -0.06910    0.35385 444.79964  -0.195  0.84526
    ## DIS3:stressstressed            -0.00962    0.33319 470.57410  -0.029  0.97698
    ## DIS1:level_id5                  0.31392    0.20148 450.29395   1.558  0.11991
    ## DIS2:level_id5                 -0.24952    0.40566 441.96825  -0.615  0.53880
    ## DIS3:level_id5                  0.37404    0.28396 422.29528   1.317  0.18848
    ## stressstressed:level_id5        0.04075    0.14618 475.15137   0.279  0.78052
    ## DIS1:stressstressed:level_id5  -0.36688    0.23255 451.42971  -1.578  0.11535
    ## DIS2:stressstressed:level_id5   0.09084    0.45245 438.90346   0.201  0.84096
    ## DIS3:stressstressed:level_id5  -0.11217    0.43651 460.93607  -0.257  0.79733
    ##                                  
    ## (Intercept)                   ***
    ## DIS1                             
    ## DIS2                             
    ## DIS3                             
    ## stressstressed                ** 
    ## level_id5                        
    ## DIS1:stressstressed              
    ## DIS2:stressstressed              
    ## DIS3:stressstressed              
    ## DIS1:level_id5                   
    ## DIS2:level_id5                   
    ## DIS3:level_id5                   
    ## stressstressed:level_id5         
    ## DIS1:stressstressed:level_id5    
    ## DIS2:stressstressed:level_id5    
    ## DIS3:stressstressed:level_id5    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

    ## 
    ## Correlation matrix not shown by default, as p = 16 > 12.
    ## Use print(x, correlation=TRUE)  or
    ##     vcov(x)        if you need it

``` r
ggplot(both_ini_V, aes(as.factor(DIS),log(PhoneDuration), color=stress))+
  geom_boxplot(outlier.shape=NA)+
  xlab('Boundary Degree 0<1<2<3')+
  ggtitle("V at word_initial in 1st vs. 3rd semester")+
  facet_wrap(~level_id,labeller=label_both)
```

![](/Users/miroolee/Documents/DataScience/L2-Prosody-Analysis/plotsunnamed-chunk-13-1.png)<!-- -->

### w/ interaction; C in wd-initial

``` r
lm4 = lmer(normedPhoneDur~DIS*stress*level_id+(1|WordLabel)+(1|Filename), data=both_ini_C)
lm5 = lmer(normedPhoneDur~DIS*stress*level_id+(1|WordLabel)+(1|Filename)+(1|PhoneLabel), data=both_ini_C)
anova(lm4, lm5) # including PhoneLabel in random intercept made the model better
```

    ## refitting model(s) with ML (instead of REML)

    ## Data: both_ini_C
    ## Models:
    ## lm4: normedPhoneDur ~ DIS * stress * level_id + (1 | WordLabel) + (1 | Filename)
    ## lm5: normedPhoneDur ~ DIS * stress * level_id + (1 | WordLabel) + (1 | Filename) + (1 | PhoneLabel)
    ##     npar     AIC     BIC logLik deviance  Chisq Df Pr(>Chisq)    
    ## lm4   19 -394.77 -319.08 216.39  -432.77                         
    ## lm5   20 -485.06 -405.38 262.53  -525.06 92.288  1  < 2.2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

``` r
summary(lm5) # C ratio was reduced when stressed.However, this effect disappeared when a syllable follows a pause greater than 1s. In the third semester, C ratio was reduced when the syllable follows a pause greater than 2s.
```

    ## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
    ## lmerModLmerTest]
    ## Formula: normedPhoneDur ~ DIS * stress * level_id + (1 | WordLabel) +  
    ##     (1 | Filename) + (1 | PhoneLabel)
    ##    Data: both_ini_C
    ## 
    ## REML criterion at convergence: -452.8
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -3.1183 -0.5232 -0.0649  0.5343  5.1312 
    ## 
    ## Random effects:
    ##  Groups     Name        Variance Std.Dev.
    ##  WordLabel  (Intercept) 0.007108 0.08431 
    ##  Filename   (Intercept) 0.003132 0.05596 
    ##  PhoneLabel (Intercept) 0.020486 0.14313 
    ##  Residual               0.011272 0.10617 
    ## Number of obs: 397, groups:  WordLabel, 105; Filename, 12; PhoneLabel, 7
    ## 
    ## Fixed effects:
    ##                                 Estimate Std. Error         df t value Pr(>|t|)
    ## (Intercept)                     0.405882   0.065366  11.142356   6.209 6.27e-05
    ## DIS1                            0.028192   0.037764 348.283291   0.747 0.455855
    ## DIS2                           -0.051921   0.072190 355.653761  -0.719 0.472473
    ## DIS3                            0.061694   0.049972 345.420681   1.235 0.217827
    ## stressstressed                 -0.125579   0.034290 146.197962  -3.662 0.000349
    ## level_id5                       0.061740   0.051629  24.184087   1.196 0.243352
    ## DIS1:stressstressed             0.012982   0.042638 350.255766   0.304 0.760946
    ## DIS2:stressstressed             0.134921   0.079919 349.585999   1.688 0.092262
    ## DIS3:stressstressed             0.164907   0.081710 310.654267   2.018 0.044431
    ## DIS1:level_id5                 -0.014032   0.058554 335.228952  -0.240 0.810759
    ## DIS2:level_id5                  0.048986   0.094533 331.023095   0.518 0.604674
    ## DIS3:level_id5                 -0.189832   0.074392 326.335035  -2.552 0.011173
    ## stressstressed:level_id5        0.004289   0.040619 363.355094   0.106 0.915970
    ## DIS1:stressstressed:level_id5  -0.035543   0.067058 338.080653  -0.530 0.596438
    ## DIS2:stressstressed:level_id5  -0.082750   0.109125 327.045183  -0.758 0.448818
    ## DIS3:stressstressed:level_id5  -0.098768   0.112892 328.885315  -0.875 0.382273
    ##                                  
    ## (Intercept)                   ***
    ## DIS1                             
    ## DIS2                             
    ## DIS3                             
    ## stressstressed                ***
    ## level_id5                        
    ## DIS1:stressstressed              
    ## DIS2:stressstressed           .  
    ## DIS3:stressstressed           *  
    ## DIS1:level_id5                   
    ## DIS2:level_id5                   
    ## DIS3:level_id5                *  
    ## stressstressed:level_id5         
    ## DIS1:stressstressed:level_id5    
    ## DIS2:stressstressed:level_id5    
    ## DIS3:stressstressed:level_id5    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

    ## 
    ## Correlation matrix not shown by default, as p = 16 > 12.
    ## Use print(x, correlation=TRUE)  or
    ##     vcov(x)        if you need it

``` r
ggplot(both_ini_C,
       aes(as.factor(DIS),normedPhoneDur, color=stress))+
  geom_boxplot(outlier.shape=NA)+
 # stat_summary(fun.data=mean_cl_boot)+
  xlab('Boundary Degree 0<1<2<3')+
  ggtitle("C at word_initial in 1st vs. 3rd semester")+
  facet_wrap(~level_id,labeller=label_both)
```

![](/Users/miroolee/Documents/DataScience/L2-Prosody-Analysis/plotsunnamed-chunk-14-1.png)<!-- -->
### syllable duration

``` r
lm6 = lmer(log(SyllDuration)~DIS*stress*level_id+(1|WordLabel)+(1|Filename), data=both_ini_C)
lm7 = lmer(log(SyllDuration)~DIS*stress*level_id+(1|WordLabel)+(1|Filename)+(1|PhoneLabel), data=both_ini_C)
summary(lm7)
```

    ## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
    ## lmerModLmerTest]
    ## Formula: log(SyllDuration) ~ DIS * stress * level_id + (1 | WordLabel) +  
    ##     (1 | Filename) + (1 | PhoneLabel)
    ##    Data: both_ini_C
    ## 
    ## REML criterion at convergence: 544.3
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -3.8556 -0.4768 -0.0356  0.4323  7.4015 
    ## 
    ## Random effects:
    ##  Groups     Name        Variance  Std.Dev.
    ##  WordLabel  (Intercept) 0.1129918 0.3361  
    ##  Filename   (Intercept) 0.0005854 0.0242  
    ##  PhoneLabel (Intercept) 0.0254051 0.1594  
    ##  Residual               0.1650928 0.4063  
    ## Number of obs: 397, groups:  WordLabel, 105; Filename, 12; PhoneLabel, 7
    ## 
    ## Fixed effects:
    ##                                Estimate Std. Error        df t value Pr(>|t|)
    ## (Intercept)                    -1.72846    0.13390  45.87145 -12.908  < 2e-16
    ## DIS1                            0.05621    0.14031 341.69393   0.401  0.68896
    ## DIS2                           -0.07402    0.27353 361.61660  -0.271  0.78685
    ## DIS3                           -0.03739    0.18695 349.02945  -0.200  0.84162
    ## stressstressed                  0.39690    0.13072 165.50026   3.036  0.00278
    ## level_id5                      -0.08678    0.13715 173.30538  -0.633  0.52775
    ## DIS1:stressstressed             0.15403    0.15876 346.19042   0.970  0.33263
    ## DIS2:stressstressed             0.29959    0.30199 357.34679   0.992  0.32184
    ## DIS3:stressstressed             0.07718    0.30901 320.20061   0.250  0.80292
    ## DIS1:level_id5                  0.02667    0.21964 339.17959   0.121  0.90343
    ## DIS2:level_id5                 -0.20240    0.35914 339.94108  -0.564  0.57342
    ## DIS3:level_id5                  0.13254    0.28220 334.94864   0.470  0.63890
    ## stressstressed:level_id5        0.10467    0.15464 372.52970   0.677  0.49893
    ## DIS1:stressstressed:level_id5  -0.14307    0.25322 345.02124  -0.565  0.57243
    ## DIS2:stressstressed:level_id5   0.02894    0.41494 338.23473   0.070  0.94444
    ## DIS3:stressstressed:level_id5  -0.07471    0.43041 336.42580  -0.174  0.86230
    ##                                  
    ## (Intercept)                   ***
    ## DIS1                             
    ## DIS2                             
    ## DIS3                             
    ## stressstressed                ** 
    ## level_id5                        
    ## DIS1:stressstressed              
    ## DIS2:stressstressed              
    ## DIS3:stressstressed              
    ## DIS1:level_id5                   
    ## DIS2:level_id5                   
    ## DIS3:level_id5                   
    ## stressstressed:level_id5         
    ## DIS1:stressstressed:level_id5    
    ## DIS2:stressstressed:level_id5    
    ## DIS3:stressstressed:level_id5    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

    ## 
    ## Correlation matrix not shown by default, as p = 16 > 12.
    ## Use print(x, correlation=TRUE)  or
    ##     vcov(x)        if you need it

``` r
ggplot(both_ini_C,
       aes(as.factor(DIS),log(SyllDuration), color=stress))+
  geom_boxplot(outlier.shape=NA)+
 # stat_summary(fun.data=mean_cl_boot)+
  xlab('Boundary Degree 0<1<2<3')+
  ggtitle("C at word_initial in 1st vs. 3rd semester")+
  facet_wrap(~level_id,labeller=label_both)
```

![](/Users/miroolee/Documents/DataScience/L2-Prosody-Analysis/plotsunnamed-chunk-15-1.png)<!-- -->
