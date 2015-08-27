;David Tulis
;CPEN 3710 lab 6
;Due 10/14/14

;This program will ask the user for input until a 0 is entered
;the numbers should be 32 bit signed integers
;once 0 is entered, we will tell the user information about each number that was entered
;specifically its sign (positive or negative), whether or not it is divisible by 16, and whether or not it can be represented with 5 decimal digits

INCLUDE Irvine32.inc
.data
positiveMsg 		BYTE "is a positive number",0
negativeMsg 		BYTE "is a negative number",0
isDiv16Msg 			BYTE "is evenly divisible by 16",0
isNotDiv16Msg 		BYTE "is not evenly divisible by 16",0
is5DigRepMsg 		BYTE "can be correctly represented in five decimal digits", 0
isNot5DigRepMsg 	BYTE "cannot be correctly represented in five decimal digits", 0

.code
main PROC
lp1: 
	call ReadInt					;get input from user. defined in irvine32.inc
	cmp eax, 0						;is the user input 0?
	jz endlp1						;if so, jump to endlp1 (exit the loop)
									;if not, display information about the number (stored in eax)
	cmp eax, 0						;compare number to 0
	jg greater						;if the element in greater than 0, go to greater
	mov edx, OFFSET negativeMsg		;if it isn't greater than 0, print negative message...
	call WriteString
	call CRLF						;move cursor down
	jmp divTest						;...and go to the next test
	greater: 
		mov edx, OFFSET positiveMsg	;print positiveMsg
		call WriteString
		call CRLF					;move cursor down

	divTest: 
	;if the number is evenly divisible by 16, eax will have the form ???? ???0 (hex)
	;so we and al with F0 (hex)
	
	
	
	
	
	jz isDivis
	mov edx, offset isNotDiv16Msg
	call WriteString
	call CRLF
	jmp Dig5RepTest
	isDivis: 
		mov edx, offset isDiv16Msg
		call WriteString
		call CRLF
	
	
	Dig5RepTest:
	cmp eax,99999
	jg cannotRep
	cmp eax,-99999
	jl cannotRep
	jmp canRep
	cannotRep:
		mov edx, OFFSET isNot5DigRepMsg
		call WriteString
		call CRLF
	jmp endIteration
	canRep:
		mov edx, OFFSET is5DigRepMsg
		call WriteString
		call CRLF

endIteration:	
jmp lp1							;start over
	
endlp1:
exit
main ENDP
END main