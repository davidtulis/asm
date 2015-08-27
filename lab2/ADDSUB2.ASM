; Title: Add and subtract
; David Tulis
; CPEN3710 lab 2
; 9/2/2014

INCLUDE Irvine16.inc
.data
val1		DWORD 10000h
val2		DWORD 40000h
val3		DWORD 20000h
finalVal 	DWORD ?

.code
main PROC
	mov ax, @data 		;puts our data in a register
	mov ds,ax			;outs our data segment register to where the data is
	mov eax,val1		;get first value
	add eax,val2		;add second value to first value
	sub eax,val3		;subtract third value from previous value
	mov finalVal, eax	;store results
	call DumpRegs		;display results
	
	exit
main ENDP
END main