;David Tulis
;CPEN3710 lab 10
;Due 11/18/14

;this program will simulate a lottery drawing.
;a structure will be defined, with fields of 5 white balls and 1 red balls
;values of the white ball are 1-59
;values of the red ball are 1-35
;one struct will be initialized with random values
;the user will than input 5 white values and 1 red value, to be stored in another struct
;we will then start matching the balls, and match the number of matches

INCLUDE Irvine32.inc

;struct to represent a lottery
;can hold 5 white balls and 1 red ball
lottery STRUCT
	wBall1 BYTE ?
	wBall2 BYTE ?
	wBall3 BYTE ?
	wBall4 BYTE ?
	wBall5 BYTE ?
	rBall1 BYTE ?
lottery ENDS

;macro to print text to the console
;parameters: num (the string to write)
mWriteString macro buffer:REQ
	push edx					;;save edx register
	mov edx, offset buffer		;;move the string to edx
	call writestring			;;write the string in edsx
	pop edx						;;restore edx register
endm

;macro to print an 8 bit value to the console\
;parameters: num (the number to write)
mPrint8 macro num
	push eax					;;save eax
	xor eax, eax				;;clear out eax
	mov al, num					;;move the 8 bit number to al
	call writedec				;;write the value to the screen
	mWriteString space			;;write a space after
	pop eax						;;restore eax
endm

;macro to print a 32 bit value to the screen
;parameters: num (the value to print)
mPrint32 macro num
	push eax					;;save eax
	mov eax, num				;;mov the number to eax
	call writedec				;;print the number
	pop eax						;;restore eax
endm

;macro will generate a single random value between 1 and the number we pass in
;parameters: num (num-1 will be the largest possible number generated)
;returns: eax (a random integer 1 through(num-1)
mRandNum macro num
	local lp0				;;local variable
	lp0:
		mov eax, num		;;mov our number to the eax register
		call RandomRange	;;generate random number 0 through (num-1)
		cmp eax, 0			;;see if the number was 0
	je lp0					;;there is no 0 ball, so if 0 is picked, we pick again
endm

;macro to print the prize strings
;parameters: 	whites 	(the number of correct white balls)
;				reds	(the number of correct red balls)
;				money	(how much money you win)
mPrintPrize macro whites, reds, money
	mWriteString match1String
	mPrint8 whites
	mWriteString match2String
	mPrint8 reds
	mWriteString match3String
	mPrint32 money
endm

.data

drawing lottery <>				;struct for the randomly generate numbers
userPicks lottery <>			;struct for the numbers the user picks

;strings to print out status messages are stored here
drawingResultsString BYTE "Powerball drawing results: White balls ",0
space BYTE " ",0
redBallString BYTE "... Red ball ",0
pleaseEnterString BYTE "Please enter your ",0
firstString BYTE "first white number: ",0
secondString BYTE "second white number: ",0
thirdString BYTE "third white number: ",0
fourthString BYTE "fourth white number: ",0
fifthString BYTE "fifth white number: ",0
redString BYTE "red number: ",0
numberString BYTE "number: ",0
match1String BYTE "You have matched ",0
match2String BYTE "white balls and ",0
match3String BYTE "red balls. You have won $",0
invalidString BYTE "Invalid input. Please try again.",0
dupString BYTE "Duplicate input. Please try again.",0
jackpotString BYTE "You matched all the balls! You have won the jackpot!",0
noPrizeString BYTE "You did not win a prize. Try again next time!",0

.code
main PROC

call generateNumbers			;generate our drawing and store in the drawing struct

								;print the generated results to the console
mWriteString drawingResultsString
mprint8 drawing.wBall1
mprint8 drawing.wBall2
mprint8 drawing.wBall3
mprint8 drawing.wBall4
mprint8 drawing.wBall5
mWriteString redBallString
mprint8 drawing.rBall1

call crlf						;next line
		

call getUserNumbers				;get user input and store in the userPicks struct

xor bx, bx						;clear out bx register, because we will use it store the number of correct matches

mov al, userPicks.wBall1		
call matchWhites 		;see if white ball 1 matches any drawn balls
mov al, userPicks.wBall2
call matchWhites 		;see if white ball 2 matches any drawn balls
mov al, userPicks.wBall3
call matchWhites 		;see if white ball 3 matches any drawn balls
mov al, userPicks.wBall4
call matchWhites 		;see if white ball 4 matches any drawn balls
mov al, userPicks.wBall5
call matchWhites 		;see if white ball 5 matches any drawn balls
						;bl contains the number of white balls matches
mov al, userPicks.rBall1
call matchRed			;see if the red ball matches the drawn red ball
						;bh contains the number of red balls matched
						
call getPrize			;match the number of drawn balls, and print the prize

exit
main ENDP

;procedure to generate random numbers
;will not generate duplicate random numbers
;will make sure the random numbers are in the correct range (1-60 or 1-35)
;returns: alters the drawing struct
generateNumbers PROC
	call randomize				;get a random seed
	mRandNum 60					;random number 1-59 in eax
	mov drawing.wBall1, al		;store the first ball

	
	tryAgain2:
		mRandNum 60				;random number 1-59 in eax
		cmp drawing.wBall1, al	;is the generated number the same as ball 1?
	je tryAgain2				;if so, try again
	mov drawing.wBall2, al		;if not, store it
	
	tryAgain3:
		mRandNum 60				;random number 1-59 in eax
		cmp drawing.wBall1, al	;is the generated number the same as ball 1?
	je tryAgain3				;if so, try again
		cmp drawing.wBall2, al	;is the generated number the same as ball 2?
	je tryAgain3				;if so, try again
	mov drawing.wBall3, al		;if not, store it
	
	tryAgain4: 
		mRandNum 60				;random number 1-59 in eax
		cmp drawing.wBall1, al	;is the generated number the same as ball 1?
	je tryAgain4				;if so, try again
		cmp drawing.wBall2, al	;is the generated number the same as ball 2?
	je tryAgain4				;if so, try again
		cmp drawing.wBall3, al	;is the generated number the same as ball 3?
	je tryAgain4				;if so, try again
	mov drawing.wBall4, al		;if not, store it
	
	tryAgain5:
		mRandNum 60				;random number 1-59 in eax
		cmp drawing.wBall1, al	;is the generated number the same as ball 1?
	je tryAgain5				;if so, try again
		cmp drawing.wBall2, al	;is the generated number the same as ball 2?
	je tryAgain5				;if so, try again
		cmp drawing.wBall3, al	;is the generated number the same as ball 3?
	je tryAgain5				;if so, try again
		cmp drawing.wBall4, al	;is the generated number the same as ball 4?
	je tryAgain5				;if so, try again
	mov drawing.wBall5, al		;if not, store it
	
	mRandNum 36					;random number 1-35 in eax
	mov drawing.rBall1, al		;store it in rBall1
	
	ret							;return to caller
generateNumbers ENDP

;procedure to get user input
;will not accept numbers outside the given range(1-60 or 1-35)
;will not accept numbers that have already been chosen
;returns: fulls the userPicks struct with the user chosen values
getUserNumbers PROC
	loop1: 
	;ask user for white 1
	mWriteString pleaseEnterString
	mWriteString firstString
	call readint
	;validate white 1
	cmp eax, 0					;is it below a 1?
	jle invalid1				;if so, invalid input
	cmp eax, 59					;is above 59
	jg invalid1					;if so, invalid input
	mov userPicks.wBall1, al	;store it in the struct
	jmp loop2					;move on to next ball
	invalid1:					;print out invalid input
	mWriteString invalidString
	call crlf
	loop loop1					;ask for input again
	
	;white 2
	loop2:
	mWriteString pleaseEnterString
	mWriteString secondString
	call readint
	;validate white 2
	cmp eax, 0					;is it below a 1?
	jle invalid2				;if so, invalid input
	cmp eax, 59					;is it above 59
	jg invalid2					;if so, invalid input
	cmp al, userPicks.wBall1	;is it the same as ball 1?
	je dup2						;if so, ask for input again
	mov userPicks.wBall2, al	;if not, store it in the struct...
	jmp loop3					;...and move on
	dup2:						;print out duplicate input
	mWriteString dupString
	call crlf
	loop loop2					;get input 2 again
	invalid2:					;print out invalid input
	mWriteString invalidString
	call crlf
	loop loop2					;get input 2 again
		
	;white 3
	loop3:
	;ask the user to input a value
	mWriteString pleaseEnterString
	mWriteString thirdString
	call readint
	;validate white 3
	cmp eax, 0					;is it below a 1?
	jle invalid3				;if so, invalid input
	cmp eax, 59					;is it above a 59?
	jg invalid3					;if so, invalid input
	cmp al, userPicks.wBall1	;is it the same as ball 1?
	je dup3						;if so, duplicate entry
	cmp al, userPicks.wBall2	;is it the same as ball 2?
	je dup3						;if so, duplicate entry
	mov userPicks.wBall3, al
	jmp loop4
	dup3:						;print out duplicate input
	mWriteString dupString
	call crlf
	loop loop3					;get input 3 again
	invalid3:					;print invald string
	mWriteString invalidString
	call crlf
	loop loop3					;get input 3 again

	;white 4
	loop4:
	mWriteString pleaseEnterString
	mWriteString fourthString
	call readint
	;validate white 4
	cmp eax, 0					;is it below 1?
	jle invalid4				;if so, invalid input
	cmp eax, 59					;is it above 59?
	jg invalid4					;if so, invalid input
	cmp al, userPicks.wBall1	;is it the same as ball 1?
	je dup4						;if so, duplicate entry
	cmp al, userPicks.wBall2	;is it the same as ball 2?
	je dup4						;if so, duplicate entry
	cmp al, userPicks.wBall3	;is it the same as ball 3?
	je dup4						;if so, duplicate entry
	mov userPicks.wBall4, al	;if it passes validation, move to wBall4
	jmp loop5					;move on to next input
	dup4: 						;print out duplicate input
	mWriteString dupString
	call crlf
	loop loop4					;get input 4 again
	invalid4:					;print out invalid string
	mWriteString invalidString
	call crlf
	loop loop4					;get input 4 again
	
	;white 5
	loop5:
	mWriteString pleaseEnterString
	mWriteString fifthString
	call readint
	;validate white 5
	cmp eax, 0					;is it below 1?
	jle invalid5				;if so, invalid input
	cmp eax, 59					;is it above 59?
	jg invalid5					;if so, invalid input
	cmp al, userPicks.wBall1	;compare white ball 1 to white ball 1
	je dup5
	cmp al, userPicks.wBall2	;compare white ball 2 to white ball 1
	je dup5
	cmp al, userPicks.wBall3	;compare white ball 3 to white ball 1
	je dup5
	cmp al, userPicks.wBall4	;compare white ball 4 to white ball 1
	je dup5
	mov userPicks.wBall5, al	;store white ball 5
	jmp loop6
	dup5:
	mWriteString dupString		;print out duplicate input
	call crlf
	loop loop5					;get input 5 again
	invalid5:					;print invalid input
	mWriteString invalidString
	call crlf
	loop loop5					;get input 5 again
	
	;red ball
	loop6:
	mWriteString pleaseEnterString
	mWriteString redString
	call readint
	;validate red ball
	cmp eax, 0					;is ball below 1?
	jle invalid6
	cmp eax, 35					;is ball above 35?
	jg invalid6
	mov userPicks.rBall1, al	;store red ball
	jmp endUserInput			;finished gathering user input
	invalid6:					;invalid input
	mWriteString invalidString
	call crlf
	loop loop6					;as for iput again
	
	endUserInput:				;finished gathering input
	ret
getUserNumbers ENDP

;this procedure will take a single user chosen white ball, and compare it to all the rng white balls
;it will keep track of the total number of white matches so far
;parameters: al (number we are checking)
;returns: bl (the total number of white matches)
;al will have the user white ball
matchWhites PROC
	cmp drawing.wBall1, al		;is it the same as rng white ball 1?
	je found
	cmp drawing.wBall2, al		;is it the same as rng white ball 2?
	je found
	cmp drawing.wBall3, al		;is it the same as rng white ball 3?
	je found
	cmp drawing.wBall4, al		;is it the same as rng white ball 4?
	je found
	cmp drawing.wBall5, al		;is it the same as rng white ball 5?
	je found
	jmp endMatchWhites			;none found, so we dont increment bl
	found:						;a match was found, so we increment bl...
	inc bl
	endMatchWhites:				;...and qui the procedure
	ret
matchWhites ENDP

;this procedure looks at the user chosen red ball, and will determine if it matches the rng red ball
;parameters: al (the value of the user-chosen red ball)
;returns: bh (the number of red matches; 0 if none, 1 if match)
matchRed PROC
	cmp drawing.rBall1, al		;does the user input match the rng value for the red ball?
	jne endMatchReds			;if not, quit the procedure
	mov bh, 1					;if so, put a 1 in bh
	endMatchReds:
	ret							;quit procedure
matchRed ENDP

;procedure to determine what prize the user wins
;looks at the number of matches white/red balls, and prints the prize accordingly
;parameters: bl (number of matched whites), bh (the number of matched reds)
;returns: nothing (prints all statements for you)
getPrize PROC

	cmp bl, 5		;are there 5 white balls matched?
	je whites5
	
	cmp bl, 4		;are there 4 white balls matched?
	je whites4
	
	cmp bl, 3		;are there 3 white balls matched?
	je whites3
	
	cmp bl, 2		;are there 2 white balls matched?
	je whites2
	
	cmp bl, 1		;are there 1 white balls matched?
	je whites1
	
	cmp bl, 0		;are there no white balls matched?
	je whites0
	
	jmp noPrize		;if we reach this point, there were none matched, so we print "no prize"
	
	whites5:				;precondition: 5 white balls matched
		cmp bh, 1			;was there a red ball match?
		je jackPot			;if so, print the jackpot
		mov eax, 1000000	;if not, print the next prize
		jmp yesPrize
	
	whites4:				;precondition: 4 white balls matched
		cmp bh, 1			;was there a red ball match?
		je whites4reds1		;if so, print 4 whites 1 red
		mov eax, 100		;if not, print 4 whites
		jmp yesPrize
		
	whites3:				;precondition: 3 whites matched
		cmp bh, 1			;was there a red ball match?
		je whites3reds1		;if so, print 3 whites 1 red
		mov eax, 7			;if not, print 3 whites
		jmp yesPrize
	
	whites2:				;precondition: 2 whites matched
		cmp bh, 1			;was there a red ball match?
		jne noPrize			;if not, there was no prize
		mov eax, 7			;if so, there was a prize. print it
		jmp yesPrize
		
	whites1:				;precondition: 1 white matched
		cmp bh, 1			;was there a red ball matched?
		jne noPrize			;if not, no prize
		mov eax, 4			;if so, print the prize
		jmp yesPrize
		
	whites0:				;precodition: no whites matched
		cmp bh, 1			;was there a red ball match?
		jne noPrize			;if not, no prize
		mov eax, 4			;if so, print prize
		jmp yesPrize
		
	jackpot: 				;prints the jackpot, and returns
		mWriteString jackpotString
		ret
	
	whites4reds1:			;prints match for 4 whites 1 red
		mov eax, 10000
		jmp yesPrize
	
	whites3reds1:			;prints match for 3 whites 1 red
		mov eax, 100
		jmp yesPrize
	
	yesPrize:				;prints the prize string, and exits
		mPrintPrize bl, bh, eax
		ret
	
	noPrize:				;prints the no prize string, and exits
		mWriteString noPrizeString
		ret
getPrize ENDP

END main