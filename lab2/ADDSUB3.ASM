; Title: Add and subtract
; David Tulis
; CPEN3710 lab 2
; 9/2/2014

INCLUDE Irvine16.inc
.data
val1		WORD 12EFh
val2		WORD 0ABCDh
val3		WORD 09A6h
finalVal 	WORD ?

.code
main PROC
	mov ax, @data 		;puts our data in a register
	mov ds,ax			;outs our data segment register to where the data is
	mov ax,val1			;get first value
	add ax,val2			;add second value to first value
	add ax,val3			;subtract third value from previous value
	mov finalVal, ax	;store results
	call DumpRegs		;display results
	
	exit
main ENDP
END main