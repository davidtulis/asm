;TITLE callee (callee.asm)

; Joe Dumas, David Tulis
; CPEN 3710 lab 11
; Due 11/25/14

; This program is called by a C++ program with the
; 3 coefficients A, B, C of the quadratic formula.
; It computes B^2 - 4AC and returns the result in EAX.
; Target: protected-address mode.

;include Irvine32.inc
.386
.model FLAT, C 

public quadform				; quadform can be called by external code

.data
zero WORD 0
two WORD 2
four WORD 4

.code

;This procedure will find the roots of a polynomial of degree 2
;parameters: float (double word) coefficients of quadratic A, B, 
;and C (Ax^2+Bx+C), and two pointers to the roots of the equation
;returns: status message to tell the caller
;if the results were complex or not
quadform proc
	
	push  ebp			; save caller's base pointer
	mov   ebp, esp			; set up a new base pointer
	
	;contents of stack:	
	;saved base pointer +0
	;return address +4
	;a +8
	;b +12
	;c +16
	;return1 +20
	;return2 +24
	
	fld real4 ptr[ebp+12]		;puts b on stack
	fld real4 ptr[ebp+12]		;puts b on stack
	fmul				;b*b on top of the stack
	fld real4 ptr[ebp+8]		;puts a on stack
	fld real4 ptr[ebp+16]		;puts c on stack
	fmul				;a*c on top of the stack
	fild four			;pushes a 4 to the stack
	fmul				;4*a*c on top of the stack

	fsub				;descriminant: b*b-4*a*c on top of the stack
	fild zero			;puts a 0 on the stack
	fcom				;compare the descriminant to 0
	fnstsw ax			;these commands fill the flags from
	sahf				;the fcom instruction so we can do a jump
	ja complexRoots			;if 0 is above the value, we will have complex roots
	fadd				;gets rid of 0 on stack
	fsqrt				;square root of descriminant
	fld real4 ptr[ebp+12]		;b
	fchs				;-b
	fadd				;-b+sqrt(descriminant)
	fild two			;2
	fld real4 ptr[ebp+8]		;a
	fmul				;2*a
	fdiv				;-b+sqrt(descriminant)/(2*a)=root
	mov edi, [ebp+20]		;set edi as the pointer to our first root
	fstp real4 ptr[edi]		;puts the first root in memory at offset edi
	
		

	fld real4 ptr[ebp+12]		;puts b on stack
	fld real4 ptr[ebp+12]		;puts b on stack
	fmul				;b*b on top of the stack
	fld real4 ptr[ebp+8]		;puts a on top of stack
	fld real4 ptr[ebp+16]		;puts c on top of stack
	fmul				;a*c at top of stack
	fild four			;puts 4 on top of stack
	fmul				;4*a*c on top of stack
	fsub				;b*b-4*a*c on top of stack
	fsqrt				;square root of descriminant
	fld real4 ptr[ebp+12]		;b on top of stack
	fchs				;-b on top of stack
	fsub st(0), st(1)		;-b-sqrt(desc) on top of stack
	fild two			;2 on top of stack
	fld real4 ptr[ebp+8]		;a on top of stack
	fmul				;2*a on top of stack
	fdiv				;root=-b-sqrt(desc)/(2*a) on top of stack
	mov esi, [ebp+24]		;esi contains the memory offset of root 2
	fstp real4 ptr[esi]		;store the root in offset esi
	
	mov eax, 0			;0 means the roots were not complex
	pop ebp				;restore base pointer register
	ret				;return to caller

	complexRoots:			;if the procedure returns complex roots
	pop ebp				;restore the base pointer register
	mov eax, -1			;-1 means the roots are complex
	ret				; return (caller to clean up args)

quadform endp

END
