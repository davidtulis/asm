; STACKPRM.ASM -- Program to demonstrate the use of the stack to pass
; arguments to, create local variables for, and save registers within,
; a subprogram.  Main program pushes two 32-bit integers on the stack,
; then calls a procedure that sets up a stack frame, creates local
; variables on the stack, and then uses the stack to save and restore
; registers that are used within the procedure.  At the end, the stack
; frame is collapsed, deallocating all local storage and parameters.
; A second, similar procedure call is done to illustrate the use of
; the ENTER and LEAVE instructions.
;
; Joe Dumas
; CPEN 3710
; August 16, 2011
;

include Irvine32.inc

	.data                      ; notice this is empty - we don't
                                   ; create any global variables ...

	.code
main    proc

        int     3                  ; invoke debugger

        mov     eax, 01234567h     ; make up some numbers to pass to procedure
        mov     ebx, 89ABCDEFh
        push    eax                ; push the two arguments onto the stack
        push    ebx                ; (they take up a total of 8 bytes)

        call    myproc             ; call procedure that uses the two numbers

        mov     eax, 01234567h     ; call myproca with same args
        mov     ebx, 89ABCDEFh
        push    eax                ; push them on the stack same as before
        push    ebx

        call    myproca            ; call alternate procedure to do the
                                   ; same thing using ENTER and LEAVE

        exit                       ; code to terminate the program

main    endp

myproc  proc
; Sample procedure to show how to access incoming parameters, create and use
; local variables, and save registers, in the procedure's stack frame
; (pointed to by EBP).  Observe the stack contents while this procedure is
; executing and you will be enlightened!
;
; Parameters: two 32-bit integers in [ebp+8], [ebp+12]
; Return value: none
; Other registers modified: none
;
        push    ebp                ; save "old" ebp value in case caller
                                   ; was using it for something
                                   ; (always do this first)

        mov     ebp, esp           ; copy the stack pointer to use as
                                   ; this procedure's base pointer
                                   ; (always do this second)

        sub     esp, 12            ; create space for three doubleword
                                   ; local variables on the stack
                                   ; (always do this after establishing
                                   ; the procedure's base pointer)

        push    eax                ; save any registers we are going to
        push    ebx                ; use (do this after allocating locals,
        push    edi                ; but before getting into the "guts" of
                                   ; the procedure)

; Note: at this point the stack frame takes up a total of 10 doublewords
; (2 for the incoming parameters, 1 for the return address, 1 for the
; saved EBP, 3 for the local variables, and 3 for the saved registers)
; so we have used a total of 40 bytes' worth of stack space.

        mov     eax, [ebp+12]      ; get first argument pushed by caller
        add     eax, [ebp+8]       ; add second argument pushed by caller
        mov     [ebp-4], eax       ; store result in one of the local vars
        mov     ebx, eax           ; copy it to EBX to play with it
        shr     ebx, 4             ; do something to it
        mov     [ebp-8], ebx       ; and store the result in another local
        lea     edi, [ebp-4]       ; just for grins, set up a pointer to
                                   ; the first result
        mov     [ebp-12], edi      ; and store the pointer in yet another
                                   ; local storage spot
        mov     ebx, [edi]         ; grab the first result and put it in
                                   ; EBX (overwriting second result)

; Ok, now we are done doing whatever it was we were doing ... time to
; start undoing the stack frame to show how that works....

        pop     edi                ; first we pop all the registers we
        pop     ebx                ; pushed (in reverse order, of course)
        pop     eax                ; now we are down to 7 doublewords of
                                   ; stack space in use

        mov     esp, ebp           ; restore the stack pointer to what it
                                   ; was before we allocated the local vars
                                   ; (this deallocates 3 more doublewords
                                   ; or 12 bytes, so now we are using only
                                   ; 4 doublewords of stack space in use)

        pop     ebp                ; restore the calling routine's EBP
                                   ; (now down to 3 doublewords of stack
                                   ; space in use - the return address
                                   ; and the two incoming parameters)

        ret     8                  ; return control to caller (pop EIP off
                                   ; stack) and deallocate the last two
                                   ; doublewords (8 bytes) of stack space
                                   ; formerly taken up by procedure parameters
myproc  endp

myproca proc
; This subprogram does the exact same computations as the previous one, but
; makes use of the ENTER and LEAVE instructions (available on the Intel 286
; and higher processors) that streamline the process of setting up and
; collapsing a stack frame.  It functions the same as myproc but has fewer
; instructions.
;
; Parameters: two 32-bit integers in [ebp+8], [ebp+12]
; Return value: none
; Other registers modified: none
;

        enter   12, 0              ; enter procedure and set up stack
                                   ; frame with 12 bytes of space reserved
                                   ; for local variables ... this takes
                                   ; the place of the three instructions ...
                                   ; push ebp
                                   ; mov ebp, esp
                                   ; sub esp, 12
                                   ; ... that we used in myproc

        push    eax                ; still need to save any registers we are
        push    ebx                ; planning to use within the procedure
        push    edi                ; (do this right after ENTER and before
                                   ; getting into the "guts" of the procedure)

; Again, at this point the stack frame takes up a total of 10 doublewords
; (2 for the incoming parameters, 1 for the return address, 1 for the
; saved EBP, 3 for the local variables, and 3 for the saved registers)
; so we have used a total of 40 bytes' worth of stack space.

        mov     eax, [ebp+12]      ; get first argument pushed by caller
        add     eax, [ebp+8]       ; add second argument pushed by caller
        mov     [ebp-4], eax       ; store result in one of the local vars
        mov     ebx, eax           ; copy it to EBX to play with it
        shr     ebx, 4             ; do something to it
        mov     [ebp-8], ebx       ; and store the result in another local
        lea     edi, [ebp-4]       ; just for grins, set up a pointer to
                                   ; the first result
        mov     [ebp-12], edi      ; and store the pointer in yet another
                                   ; local storage spot
        mov     ebx, [edi]         ; grab the first result and put it in
                                   ; EBX (overwriting second result)

; Ok, now we are done doing whatever it was we were doing ... time to
; start undoing the stack frame to show how that works....

        pop     edi                ; again we pop all the registers we
        pop     ebx                ; pushed (in reverse order, of course)
        pop     eax                ; now we are down to 7 doublewords of
                                   ; stack space in use

        leave                      ; this restores the old stack pointer
                                   ; and base pointer values and deallocates
                                   ; the storage for the local variables ...
                                   ; (takes the place of the two instrs ...
                                   ; mov esp, ebp
                                   ; pop ebp
                                   ; ... that we used in myproc)
                                   ;
                                   ; (we're down to 3 doublewords of stack
                                   ; space in use - the return address
                                   ; and the two incoming parameters)

        ret     8                  ; return control to caller (pop EIP off
                                   ; stack) and deallocate the last two
                                   ; doublewords (8 bytes) of stack space
                                   ; formerly taken up by procedure parameters
myproca endp

	end     main