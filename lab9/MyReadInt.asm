MyReadInt PROC uses ebx ecx edx esi
; Modified from Irvine32.asm by Dr. Joe Dumas
; Reads a 32-bit unsigned decimal integer from standard
; input, stopping when the Enter key is pressed.
; All valid digits occurring before a non-numeric character
; are converted to the integer value. Leading spaces are
; ignored, and an optional leading + sign is permitted.

; Receives: nothing
; Returns:  If CF=0, the integer is valid, and EAX = binary value.
;   If CF=1, the integer is invalid and EAX = 0.
.data
LMAX_DIGITS = 80
Linputarea    BYTE  LMAX_DIGITS dup(0),0
overflow_msgL BYTE  " <32-bit integer overflow>",0
invalid_msgL  BYTE  " <invalid integer>",0
neg_msg       BYTE  " <negative numbers not allowed>",0
.code

; Input a string of digits using ReadString.

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
	jne   L4              		; no: must be a digit
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