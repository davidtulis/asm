;David Tulis bqb428
;CPEN 3710 lab 7 and lab 8
;Due 11/4/14

;This code will take the two arrays defined below and sort them in ascending order
;using the selection sort algorithm. They will be sorted in place, 

INCLUDE Irvine32.inc
.data
array1 SWORD 0C0Dh, 0003h, 0FFAAh, 0F70h, 0000h, 0E222h, 0ABCDh, 0123h
;			 3085	0003   -86     3952       0  -7646   -21555   291

;sorted:     -21555, -7646, -86,    0,    3,    291,   3085, 3952
;            0ABCDh  0E222h 0FFAAh  0000  0003  0123h  0C0Dh 0F70h
array2 SWORD 61A8h, 024Fh, 0EC01h, 0FAEEh, 2C03h, 8472h, 63AAh, 0CD45h, 2222h, 61B1h, 7A4Eh, 8100h, 0FDB2h, 6543h, 0FFFFh
array1Largest SWORD ?
array2Largest SWORD ?
array1name BYTE "array1: ",0
array2name BYTE "array2: ",0
largestString BYTE "largest element of ",0
sortingString BYTE "SORTING ",0

.code
main proc

;print array1
mov edx, offset array1name
call WriteString
mov esi, offset array1
mov ecx, lengthof array1
mov ebx, type array2
call dumpmem
call crlf

;print array2
mov edx, offset array2name
call WriteString
mov esi, offset array2
mov ecx, lengthof array2
mov ebx, type array2
call dumpmem
call crlf

;print "sorting"
mov edx, offset sortingString
call WriteString
mov edx, offset array1Name
call WriteString
call crlf

;call sort on first array
mov edi, offset array1
mov ecx, lengthof array1
;parameters: edi (starting location of the array), ecx (size of array)
;returns: ax (largest element)
call sort

;print array1
mov edx, offset array1name
call WriteString
mov esi, offset array1
mov ecx, lengthof array1
mov ebx, type array2
call dumpmem
call crlf

;print array2
mov edx, offset array2name
call WriteString
mov esi, offset array2
mov ecx, lengthof array2
mov ebx, type array2
call dumpmem
call crlf

;print largest of first array
mov edx, offset largestString
call WriteString
mov edx, offset array1name
call WriteString
cwd							;ax has the largest value, so we clear up the upper part of eax
call WriteHex
call crlf

;print "sorting"
mov edx, offset sortingString
call WriteString
mov edx, offset array2Name
call WriteString
call crlf

;second call
mov edi, offset array2
mov ecx, lengthof array2
;parameters: edi (starting location of the array), ecx (size of array)
;returns: ax (largest element)
call sort

;print array1
mov edx, offset array1name
call WriteString
mov esi, offset array1
mov ecx, lengthof array1
mov ebx, type array2
call dumpmem
call crlf

;print array2
mov edx, offset array2name
call WriteString
mov esi, offset array2
mov ecx, lengthof array2
mov ebx, type array2
call dumpmem
call crlf

;print largest of second array
mov edx, offset largestString
call WriteString
mov edx, offset array2name
call WriteString
mov edi, offset array2Largest
cwd							;ax has the largest value, so we clear up the upper part of eax
call WriteHex
call crlf

exit
main ENDP


;parameters: edi (starting location of the array), ecx (size of array)
;returns: ax (largest element)
sort proc
mov edx, ecx
loop_i: 
	;we need this compare and jump to fix an off by 1 error. Since the loop checks if ecx is 0, 
	;before continuing, the last loop will have ecx as 0. When we decrement ecx inside the loop, 
	;it becomes FFFFFFFFh, which we just can't have. The last element will already be in place before
	;the last iteration
	cmp ecx, 1			
	je finished
	push edx

	mov eax, edx		;eax is our pointer that looks at the elements
	add eax, edx		;we have dwords in memory, so the size is 2*n
	sub eax, ecx		;we initialize it to: 2*size of array-2*current loop count, ecx
	sub eax, ecx		;since we have dwords in memory, we will have 2*n-2*ecx
	
	mov ebx, edx		;ebx contains a pointer to the smallest element
	add ebx, edx		
	sub ebx, ecx		;we initialize it to: 2*size of array-2*current loop count, ecx
	sub ebx, ecx
	
	add eax, 2			;increment our pointer to look at the next element
	push ecx			;save loop_i counter
	dec ecx				;decrement the counter, since we already have two elements loaded in
	loop_j:				;inner loop for finding the smallest element
		mov bp, [edi+eax]	;the next value in the array
		cmp [edi+ebx], bp	;the smallest value
		jl notSmaller		;the element is not smaller, so we skip the update
		mov ebx, eax		;we have found a new smallest element! put it in ebx
		notSmaller: 
		add eax, 2			;go to the next element
	loop loop_j				
	pop ecx					;restore loop_i counter
	pop edx					;restore size of the array
	;code to swap
	push esi
	
	mov eax, edx
	add eax, edx		;2*size of array
	sub eax, ecx		;2*loop interation count
	sub eax, ecx		;the element at: 2*size of array-2*loop iteration
	
	mov si, [edi+eax]	;the first element of the unsorted section in si
	xchg si, [edi+ebx]	;exchange the smallest element with the si register
	mov [edi+eax], si	;put the si register in the beginning of the unsorted section
	
	pop esi

loop loop_i	
	finished:
	add edx, edx		;since we have words, the size in memory is 2*edx
	sub edx, 2			;move it back to the last element
	mov ax, [edi+edx]	;last element is the largest into ax
ret	
sort endp
END main
