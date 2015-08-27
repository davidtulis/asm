;David Tulis bqb428
;CPEN3710 lab 5
;10/7/14

;This program will either add or subtract some unsigned 96 bit numbers stored in memory

INCLUDE Irvine32.inc
.data
;these are stored in little endian, so least significant comes first in the array
add1 DWORD 35D9607Bh, 552677F5h, 48C2E4C3h
add2 DWORD 0ED40C392h, 4F1792C6h, 11572495h
sub1 DWORD 24C2F0ABh, 164E95A2h, 10792731h 
sub2 DWORD 3C7F1265h, 2324642Eh, 086234E5h, 

resultadd DWORD 3 DUP(?)		;these are our results array
resultsub DWORD 3 DUP(?)

.code
main PROC
mov eax, OFFSET add1			;memory offset of first operand
mov ebx, OFFSET add2			;memory offset of second operand
mov si, 0						;control flag to specify desired operation. 0 indicates addition
call subproc					;the stack now contains: EIP

call dumpregs
mov esi, offset add1			;setting up DUMPMEM for add1
mov ecx,lengthof add1
mov ebx,type add1
call DumpMem
mov esi, offset add2			;setting up DUMPMEM for add2
mov ecx,lengthof add2
mov ebx,type add2
call DumpMem
mov esi, offset resultadd		;setting up DUMPMEM
mov ecx,lengthof resultadd
mov ebx,type resultadd
call DumpMem

mov eax, OFFSET sub1			;memory offset of first operand
mov ebx, OFFSET sub2			;memory offset of second operand
mov si, 1						;1 indicates subtraction
call subproc					;subtraction

call DumpRegs
mov esi, offset sub1			;setting up DUMPMEM for sub1
mov ecx,lengthof sub1
mov ebx,type sub1
call DumpMem
mov esi, offset sub2			;setting up DUMPMEM for sub2
mov ecx,lengthof sub2
mov ebx,type sub2
call DumpMem
mov esi, offset resultsub		;setting up DUMPMEM
mov ecx,lengthof resultsub
mov ebx,type resultsub
call DumpMem

exit
main ENDP

subproc PROC					;the stack now contains: eip
CMP si, 1						
jnz addition					;if it is zero, go to addition, otherwise continue with subtract
subtraction: 
	mov ecx, 3					;initialize our loop counter to the 3 parts of our 96 bit numbers
	mov esi, OFFSET resultsub	;memory offset of our result will be stored in esi
	clc							;clear carry flag, because there is not any carry (initially)
	pushf						;push our flags (to balance our stack)
	lp1: 
		mov edx, [eax]			;edx is temporary storage for our arithmetic
		popf					;restore flags
		sbb edx, [ebx]			;subtract with borrow
		pushf					;save flags
		mov [esi], edx			;move our answer to our results array
		add eax, 4				;increment to next part of our arrays
		add ebx, 4
		add esi, 4
		loop lp1
	popf						;clear out the stack so we can get our EIP register back
	jmp endprogram				;skip the addition section and exit the procedure
	
addition: 
	mov ecx, 3					;initialize our loop counter to the 3 parts of our 96 bit numbers
	mov esi, OFFSET resultadd	;memory offset of our result will be stored in esi
	clc							;clear carry flag, because there is not any carry (initially)
	pushf						;push our flags (to balance our stack)
	lp2: 
		mov edx, [eax]			;edx is temporary storage for our arithmetic
		popf					;restore flags
		adc edx, [ebx]			;add the numbers with carry flag
		pushf					;save flags
		mov [esi], edx			;move to answer
		add eax, 4				;increment to the next part of our arrays
		add ebx, 4
		add esi, 4
		loop lp2
	popf						;clear out the stack so we can get back to our EIP register
endprogram: 
ret	
subproc endp
END main
