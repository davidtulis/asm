; David Tulis
; Lab 4
; 9/16/14

;This program will print out the first 32 numbers in the Fibonacci sequence

INCLUDE Irvine32.inc
.data
fibArray DWORD 1, 1, 30d DUP(?)				;this is where we will store the fibonacci sequence
											
.code
main PROC
	int 3									;used to trigger breakpoint
	mov ecx,30								;loop counter. 30 instead of 32, because the first
											;2 numbers are already in the fibArray
	mov esi,OFFSET fibArray
	lp:
		mov eax,[esi]						;element 1 of fib sequence in register eax
		add esi,4							;move forward to next element in fibArray
		add eax,[esi]						;element 1 + element 2 of fib sequence in eax
		add esi,4							;move forward to next element in fibArray
		mov [esi],eax						;put eax in the next part of fibArray
		sub esi,4							;move backwards in fibArray
		call DumpRegs
		LOOP lp
	mov esi,OFFSET fibArray
	mov ecx,LENGTHOF fibArray
	mov ebx,TYPE fibArray
	call DumpMem
exit
main ENDP
END main