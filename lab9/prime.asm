;David Tulis bqb428
;CPEN3710 lab 9
;Due 11/11/14

;This program will ask the user for input. The user will input an unsigned 32 bit value
;The program will pass value to a procedure, which will test the number for primality
;using a non-probablistic primality test. If the number is prime, a 0 will be returned
;if the number is not prime, the procedure will return one of the number's divisors
;the program will exit if the user enters a 0
;the program will display an error message if the user enters anything but positive numbers
;elapsed time will be printed after each test
;note: 1 is not prime. inputting a 1 should return 1

INCLUDE Irvine32.inc
.data
inputString BYTE "Enter a non-negative integer (0 to exit):",0
isPrimeString BYTE " is a prime number",0
isNotPrimeString BYTE " is not a prime number; it is divisible by ",0
exitString BYTE "Exiting program...",0
computationString BYTE "This computation took ",0
msString BYTE " milliseconds",0

LMAX_DIGITS = 80
Linputarea    BYTE  LMAX_DIGITS dup(0),0
overflow_msgL BYTE  " <32-bit integer overflow>",0
invalid_msgL  BYTE  " <invalid integer>",0
neg_msg       BYTE  " <negative numbers not allowed>",0

.code

;this macro will print a 32 bit number on screen
;parameters: the 32 bit number
mPrintDec32 MACRO num
push eax
mov eax, num
call writedec
pop eax
endm

;this macro will print an 8 bit number on screen
;parameters: the 8 bit number
mPrintDec8 MACRO num
push eax
xor eax, eax
mov al, num
call writedec
pop eax
endm

;our main procedure
main proc

lp:										;our loop for getting user input
	mov edx, offset inputString			;ask user to input integer
	call writestring
	
	;cf=0, eax!=0 if valid
	;cf=1, eax=0 if invalid
	;cf=0, eax=0 if exit
	call myreadint						;get input from user
	pushf								;save our flags for when we determining input validity
	cmp eax, 0							;if eax=0, the input is either invalid or exit code
	je invalidOrExit					
		
	push eax							;save eax (for after we call isPrime)
	push eax							;save eax (for after we call getmseconds)
	
	call getmseconds					;get time started
	mov esi, eax						;save in esi
	pop eax								;restore eax (our original value)
	

	call isPrime						;test if eax is prime
	
	push eax							;save results of primality test
	call getmseconds					;get time finished
	mov edi, eax						;save in edi
	pop eax								;restore results of primality test to eax
	
	cmp eax, 0							;if eax=0, the number is prime
	pop ebx								;ebx contains the value we tested
	jne notPrime						;if not, execute notPrime code
	
	
	mPrintDec32 ebx						;print our original value
	mov edx, offset isPrimeString		;tell the user it is prime
	call writestring
	call crlf
	jmp nextLoop						;get another input from user
	
	notPrime: 							;if ebx!=0, the number is not prime
	mPrintDec32 ebx						;print our original value
	mov edx, offset isNotPrimeString	
	call writestring					;tell the user it is not prime
	call WriteDec						;give a divisor of the number
	call crlf
	
	nextLoop:
	sub edi, esi						;time ended-time started=run time
	mov edx, offset computationString	;print "runtime is: "
	call writestring
	mPrintDec32 edi						;print runtime
	mov edx, offset msString			;print "milliseconds"
	call writestring
	call crlf


jmp lp

invalidOrExit:				;do we need to exit or loop again?
popf						;restore our flags
jns lp						;a sign flag means we need to exit

mov edx, offset exitString
call writestring

exit
main ENDP

;tests if the number in eax is prime
;parameters: eax (the number we want to test)
;returns: eax (0 if the number is prime, a divisor if the number is not prime)
;will only modify eax
isPrime PROC uses edi edx ecx ebx
push ebp					;save old base pointer
mov ebp, esp				;initialize the base pointer as the stack pointer
;sub esp, 4					;create space for a doubleword on the stack
mov eax, [ebp+24]			;stack contents are as follows: 
							;old base pointer
							;return address +4
							;ebx +8
							;ecx +12
							;edx +16
							;edi +20
							;the number we want to test +24
;we must test up to the square root of eax
mov ecx, eax				;the number we are testing for primality will be referred to as P

;test if P=1
cmp eax, 1
je case1					;1 is not prime

;test if P=2
cmp eax, 2
je primeFound

;test if P is even
xor edx, edx				;clear out edx
push eax					;save P
mov edi, 2					;number is even if num%2=0
div edi           
pop eax						;restore P
cmp edx, 0					;if edx is 0, we know 2 goes into it evenly
je caseEven


lp2: 						;our loop for testing primality

;iterate through numbers 3, 5, 7...sqrt(eax)
mov ebx, eax
sub ebx, ecx				;ebx, the divisor we are testing
add ebx, 3					;start at 3

;the test to end the loop
push eax
mov eax, ebx				;ebx is the divisor we are testing
mov edx, ebx
mul edx						;result will be in edx:eax
;loop should exit if the result of this multiplication is greater than P
cmp edx, 0
jne primeFound

;restore eax to edx, because we need to test how the number compares to eax
pop edx						;edx now contains P
cmp eax, edx				;if the result of the multiplication is greater than P
ja primeFound				;we have testing up to sqrt(P), and it IS prime

mov eax, edx				;eax has P again


xor edx, edx				;clear our edx
push eax					;save eax
div ebx						;divide what is in edx:eax by ebx
pop eax						;balance stack by restoring P to eax
cmp edx, 0					;edx stores the remainder of the division. 
je notPrime					;if the remainder=0, it is evenly divisble, therefore not prime


dec ecx						;this decrement will make the loop counter skip even numbers
loop lp2					;test next number

primeFound: 	
	mov eax, 0				;if P is prime, eax will be 0
	jmp return				;exit procedure

notPrime: 
	mov eax, ebx				;move the divisor into eax
	jmp return					;exit procedure

case1:						;special case if P=1
	mov eax, 1				
	jmp return
caseEven:					;special case if P is even
	mov eax, 2

return:
pop ebp						;balance our registers


ret
isPrime ENDP




; Modified from Irvine32.asm by Dr. Joe Dumas
; Reads a 32-bit unsigned decimal integer from standard
; input, stopping when the Enter key is pressed.
; All valid digits occurring before a non-numeric character
; are converted to the integer value. Leading spaces are
; ignored, and an optional leading + sign is permitted.

; Receives: nothing
; Returns:  If CF=0, the integer is valid, and EAX = binary value.
;   If CF=1, the integer is invalid and EAX = 0.

; Input a string of digits using ReadString.
MyReadInt PROC uses ebx ecx edx esi

	mov   edx,offset Linputarea
	mov   esi,edx           	; save offset in ESI
	mov   ecx,LMAX_DIGITS
	call  ReadString
	mov   ecx,eax           	; save length in ECX
	cmp   ecx,0            		; greater than zero?
	jne   L1              		; yes: continue
	mov   eax,0            		; no: set return value
	jmp   L9              		; and exit

; Skip over any leading spaces.

L1:	mov   al,[esi]         		; get a character from buffer
	cmp   al,' '          		; space character found?
	jne   L2              		; no: check for a sign
	inc   esi              		; yes: point to next char
	loop  L1
	jcxz  L8              		; quit if all spaces

; Check for a leading sign.

L2:	cmp   al,'-'          		; minus sign found?
	jne   L3              		; no: look for plus sign
	mov   edx, offset neg_msg       ; tell user negative numbers not allowed
        jmp   L8
L3:	cmp   al,'+'          		; plus sign found?
	jne   L3A              		; no: must be a digit
	inc   esi              		; yes: skip over the sign
	dec   ecx              		; subtract from counter

; Test the first digit, and exit if it is nonnumeric.

L3A:mov  al,[esi]		; get first character
	call IsDigit		; is it a digit?
	jnz  L7A		; no: show error message

; Start to convert the number.

L4:	mov   eax,0           		; clear accumulator
	mov   ebx,10          		; EBX is the divisor

; Repeat loop for each digit.

L5:	mov  dl,[esi]		; get character from buffer
	cmp  dl,'0'		; character < '0'?
	jb   L9
	cmp  dl,'9'		; character > '9'?
	ja   L9
	and  edx,0Fh		; no: convert to binary
	push edx
	mul  ebx		; EDX:EAX = EAX * EBX
	pop  edx

	jo   L6			; quit if result too big for 32 bits
	add  eax,edx         	; add new digit to AX
	jo   L6			; quit if result too big for 32 bits
	inc  esi              	; point to next digit
	jmp  L5			; get next digit

; Carry out of 32 bits has occured, choose "integer overflow" messsage.

L6:	mov  edx,OFFSET overflow_msgL
	jmp  L8

; Choose "invalid integer" message.

L7A:
	mov  edx,OFFSET invalid_msgL

; Display the error message pointed to by EDX.

L8:	call WriteString
	call Crlf
	stc			; set Carry flag
	mov  eax,0            	; set return value to zero and exit
L9:	ret
MyReadInt ENDP





END main

