# This script goes through sound and TextGrid files in a directory,
# opens each pair of Sound and TextGrid, calculates the duration
# of each labeled interval in the phone tier, 
# the pitch maximum at the center of the phone, and
# the duration of the corresponding interval in the syllable tier, 
# and then saves the results to a text file.
#
# To make some other or additional analyses, you can modify the script
# yourself... it should be reasonably well commented! ;)
#
# This script is distributed under the GNU General Public License.
# 25.11.2004 Mietta Lennes
# 2019-09-24 Tested and updated on Praat v6.1.03 / ML



form Analyze durations of segments and the corresponding words
	comment Directory of sound files
	text sound_directory /Users/miroolee/UPitt/L2 Prosody Project/ELI analysis/KR/
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files
	text textGrid_directory /Users/miroolee/UPitt/L2 Prosody Project/ELI analysis/KR/
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting text file:
	text resultfile /Users/miroolee/UPitt/L2 Prosody Project/ELI analysis/KR/duration_results.txt
	comment Which tier contains the speech sound segments?
	sentence Segment_tier segment
	comment Which tier contains the syllable orders?
	sentence Syllable_tier syllable
	comment Which tier contains the words?
	sentence Word_tier word
	comment Pitch analysis parameters
	real Time_step 0.0 (=auto)
	positive Minimum_pitch 75
	positive Maximum_pitch 500
endform

# Here, you make a listing of all the sound files in a directory.

Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Check if the result file exists:
if fileReadable (resultfile$)
	pause Overwrite the old result file 'resultfile$'?
	deleteFile: resultfile$
endif

# Write a row with column titles to the result file:
# (remember to edit this if you add or change the analyses!)

titleline$ = "Filename	PrecedingPhone	PhoneLabel	FollowingPhone	StartingPoint	PhoneDuration	PitchMaxInPhone	SyllLabel	SyllDuration	WordLabel	WordDuration	IsVowel	'newline$'"
fileappend "'resultfile$'" 'titleline$'

# Go through all the sound files, one by one:

for ifile to numberOfFiles
	filename$ = Get string... ifile

	# A sound file is opened from the listing:
	Read from file... 'sound_directory$''filename$'

	# Starting from here, you can add everything that should be 
	# repeated for every sound file that was opened:
	soundname$ = selected$ ("Sound", 1)

	# Open a TextGrid by the same name:
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'

		# Find the tier number that has the label given in the form:
		call GetTier 'segment_tier$' segment_tier
		call GetTier 'syllable_tier$' syllable_tier
		call GetTier 'word_tier$' word_tier
		if segment_tier > 0 and word_tier > 0
			Convert to Unicode
			numberOfIntervals = Get number of intervals... segment_tier
			preceding_label$ = ""
			following_label$ = ""
			#wordfinal$ = "no"
			select Sound 'soundname$'
			To Pitch... time_step minimum_pitch maximum_pitch
			select TextGrid 'soundname$'
			# Pass through all intervals in the selected segment tier:
			for interval to numberOfIntervals
				label$ = Get label of interval... segment_tier interval
				
				isVowel$ = "no"
				if label$ <> ""
					# if the interval has an unempty label, get its start and end:
					start = Get starting point... segment_tier interval
					end = Get end point... segment_tier interval

					# get the duration of the phone segment
					phonedur = end - start

					# get the time at the middle of the phone:
					phonecenter = (start + end) / 2
					select Pitch 'soundname$'
					pitchmax = Get maximum... start end Hertz Parabolic
					select TextGrid 'soundname$'

					# get the word interval number at the phone center:
					word = Get interval at time... word_tier phonecenter
					
					# get the label of that word:
					word_label$ = Get label of interval... word_tier word
					wordstart = Get starting point... word_tier word
					wordend = Get end point... word_tier word
					
					# get the duration of the word:
					worddur = wordend - wordstart
					
					# get the syllable interval number at the phone center:
					syllable = Get interval at time... syllable_tier phonecenter
					# get the label of that syllable:
					syll_label$ = Get label of interval... syllable_tier syllable
					syllstart = Get starting point... syllable_tier syllable
					syllend = Get end point... syllable_tier syllable

					# get the duration of the syllable:
					sylldur = syllend - syllstart

					# replace "/" in syllLabel to "_"
					
					if index_regex(syll_label$, "/") > 0
						new_syll_label$ = replace$(syll_label$, "/", "_", 0)
						
					endif
			
					# get the following label
					if interval < numberOfIntervals
					following_label$ = Get label of interval... 4 interval+1
						if following_label$ = ""
							following_label$ = Get label of interval... 4 interval+2
						endif
					else
						following_label$ = "END"
					endif

					# get the interval number of the last segment in the current syllable
					notlastseg = Get interval at time... segment_tier syllend
					lastseg = notlastseg-1
					
					# check if interval contains "+V"
					for interval+1 to lastseg
						lastseg_label$ = Get label of interval... segment_tier interval
						if index_regex(lastseg_label$, "\+V") > 0
							isVowel$ = "no"
						elsif index_regex(lastseg_label$, "V") > 0
							isVowel$ = "yes"
						endif
					endfor

				

					# Save result to text file:
					resultline$ = "'soundname$'	'preceding_label$'	'label$'	'following_label$'	'start:3'	'phonedur:3'	'pitchmax:0'	'new_syll_label$'	'sylldur:3'	'word_label$'	'worddur:3'	'isVowel$'	'newline$'"
					fileappend "'resultfile$'" 'resultline$'
					select TextGrid 'soundname$'
			
				preceding_label$ = label$
				endif
			
			endfor
			# Remove the Pitch object
			select Pitch 'soundname$'
			Remove
		endif
		# Remove the TextGrid object from the object list
		select TextGrid 'soundname$'
		Remove
	endif
	# Remove the sound object from the object list
	select Sound 'soundname$'
	Remove
	select Strings list
	# and go on with the next sound file!
endfor

Remove


#-------------
# This procedure finds the number of a tier that has a given label.

procedure GetTier name$ variable$
        numberOfTiers = Get number of tiers
        itier = 1
        repeat
                tier$ = Get tier name... itier
                itier = itier + 1
        until tier$ = name$ or itier > numberOfTiers
        if tier$ <> name$
                'variable$' = 0
					printline The tier called 'name$' is missing from the file 'soundname$'!
        else
                'variable$' = itier - 1
        endif

endproc
