;David Tulis bqb428
;CPEN3710 lab 12
;Due 12/1/14

;this is a real mode program
;user can either inputs name of file+extension as a command line argument
;or the user can not enter any arguments and enter the name in the command line
;if the file exists in the current directory, we open it
;print out file name and date last modified
;format: 5:05 a.m. January 6, 2014

;if the file does not exist, we must display an error message
;we must not change the file (open it in read only mode)

Include Irvine16.inc

;macro to write a string to the console
mWriteString MACRO buffer:REQ
	push dx
	mov dx, offset buffer
	call writestring
	pop dx
ENDM

;macro to write a word to the console
mWriteDecWord MACRO num:REQ
	push ax
	mov ax, num
	call writedec
	pop ax
ENDM

.data
enterString byte "Enter name of file: ",0
modifiedString byte "was last modified at ",0
onString byte "on ",0
file byte 11 DUP(?)			;11 is the max file name size in FAT
fileNotFoundString byte "File not found, please try again",0
errorString byte "Error getting date info from file",0
am byte "a.m. ",0
pm byte "p.m. ",0
space byte " ",0
colon byte ":",0
comma byte ", ",0
janString BYTE "January ",0
febString BYTE "February ",0
marString BYTE "March ",0
aprString BYTE "April ",0
mayString BYTE "May ",0
junString BYTE "June ",0
julString BYTE "July ",0
augString BYTE "August ",0
sepString BYTE "September ",0
octString BYTE "October ",0
novString BYTE "November ",0
decString BYTE "December ",0
errorMonthString BYTE "Error printing month",0

.code
main PROC
	mov ax, @data		;move address of data segment into ax
	mov ds, ax		;set ds as our data segment
	
	mov dx, offset file	;move the buffer into dx
	call getcommandtail	;call to get the command tail and put it in the buffer specified by dx
	jnc skipUserInput	;a cleared carry flag means no command line args, so we ask the user for input
	
	input:
	mWriteString enterString	;ask the user to input a file name
	
	mov dx, offset file			;the offset in memory of the name of the file
	mov cx, sizeof file			;the size of the buffer
	call readstring				;get filename from user
	
	skipUserInput:				;we jump here if the command line args were empty
	
	mov ah, 3dh		;open file
	mov al, 0		;read only
	mov dx, offset file	;file name
	int 21h			;ax has file handle
	jc fileNotFound		;carry flag set means the file was not found
	mov bx, ax		;bx has file handle
	
	mov ah, 57h		;get a file's date and time stamp
	mov al, 00h		;get
				;bx has file handle
	int 21h			;cx has time, dx has date
	jc errorDate		;carry flag means there was some error
	push cx			;save cx, because we will be shifting it around
	
	mWriteString file	;print name of file
	mWriteString space	;print a space
	mWriteString modifiedString	;print "was last modified on"
	
	;0-11 for am, no convert
	;12 for pm, no convert
	;13-24 for pm, convert
	
	;hours
	shr cx, 11			;clear out the rest of cx
	cmp cx, 0			;is cx midnight?
	je midnight			;at midnight, 0 becomes 12am
	cmp cx, 11			;is cx less than or equal to 11		
	jbe noConvertTime		;all times below 11 require no converstion, and an am flag
	cmp cx, 12			;is cx noon?
	je noon				;at noon, we need to set the pm flag, but we dont need to convert
	sub cx, 12			;for all other cases, we convert and set the pm flag
	mov al, 1			;1 means pm
	jmp endConvert			;not any special case
	
	midnight:			
	mov cx, 12			;0 hours=12 hours
	mov al, 0			;0 means am
	jmp endConvert
	noConvertTime:			
	mov al, 0			;0 means am
	jmp endConvert
	noon:				
	mov al, 1			;1 means pm
	endConvert:
	mWriteDecWord cx		;write the hours
	mWriteString colon		;write a colon
	
	;minutes
	pop cx				;restore cx
	shl cx, 5			;clear out left side
	shr cx, 10			;clear out right side
	mWriteDecWord cx		;write the minutes
	mWriteString space		;write a space
	
	cmp al, 0			;is the am/pm flag 0
	je amCase			;if it is 0, the time is am
	mWriteString pm			;if not, the time is pm
	jmp endAmPm			;jump over
	amCase:
	mWriteString am			;the time is am if al=0
	endAmPm:
	
	push dx				;dx is our date, which we want to save
	shl dx, 7			;clear out dx
	shr dx, 12			;put the month part in the least significant bits
	
	;this big ol switch statements looks at dx, and prints the month string
	;depending on the value (1=january, 2=febuary, etc...)
	cmp dx, 1
	je jan
	cmp dx, 2
	je feb
	cmp dx, 3
	je mar
	cmp dx, 4
	je apr
	cmp dx, 5
	je may
	cmp dx, 6
	je jun
	cmp dx, 7
	je jul
	cmp dx, 8
	je aug
	cmp dx, 9
	je sep
	cmp dx, 10
	je oct
	cmp dx, 11
	je nov
	cmp dx, 12
	je dece
	jan:
	mWriteString janString
	jmp endMonth
	feb:
	mWriteString febString
	jmp endMonth
	mar:
	mWriteString marString
	jmp endMonth
	apr:
	mWriteString aprString
	jmp endMonth
	may:
	mWriteString mayString
	jmp endMonth
	jun:
	mWriteString junString
	jmp endMonth
	jul:
	mWriteString julString
	jmp endMonth
	aug:
	mWriteString augString
	jmp endMonth
	sep:
	mWriteString sepString
	jmp endMonth
	oct:
	mWriteString octString
	jmp endMonth
	nov:
	mWriteString novString
	jmp endMonth
	dece:
	mWriteString decString
	jmp endMonth
	errorWiteMonth:
	mWriteString errorMonthString	
	endmonth:
	
	pop dx				;restore dx
	push dx				;save it again
	
	shl dx, 11			;clear out the bits we dont need
	shr dx, 11			;move the bits to the least significant position
	
	mWriteDecWord dx		;write the date
	mWriteString comma		;write a comma
	
	pop dx				;restore dx to print year
	shr dx, 9			;move the year to the last significant position
	add dx, 1980		;add 1980, because our MSDOS call gets the number of years since 1980
	mWriteDecWord dx	;write the year
	
	exit				;end
	
	fileNotFound:			;if the file was not found
	mWriteString fileNotFoundString	;print that the file was not found
	call crlf
	jmp input			;ask for input again
	
	errorDate:			;if there was a date obtaining date info
	mWriteString errorString	;print the error string
	mWriteDecWord ax		;print the error number
	exit				;exit
main ENDP

;this procedure was written by irvine, and was copied from the book, pages 590-591
;returns cf=1 if no command line args are given, cf=0 if everything is OK
;puts the command tail into a buffer, whose offset is specified by dx
getcommandtail PROC
push es
pusha

mov ah, 62h
int 21h
mov es, bx
mov si, dx
mov di, 81h
mov cx, 0
mov cl,es:[di-1]
cmp cx, 0
je L2
cld
mov al, 20h
repz scasb
jz L2
dec di
inc cx
L1:
mov al,es:[di]
mov [si],al
inc si
inc di
loop L1
clc
jmp L3
L2:
stc
L3:
mov byte ptr [si],0
popa
pop es
ret
getcommandtail ENDP
END main
