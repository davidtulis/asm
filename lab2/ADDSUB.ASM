; Title: Add and subtract
; David Tulis
; CPEN3710 lab 2
; 9/2/2014

INCLUDE Irvine32.inc
.code
main PROC

	mov eax,10000h		;EAX=10000h
	add eax,40000h		;EAX=50000h
	sub eax,20000h		;EAX=30000h
	call DumpRegs		;display contents of registers
	
	exit
main ENDP
END main