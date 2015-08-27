;David Tulis
;CPEN3710 lab 11
;Due 11/25/14

.model small, C

INCLUDE Irvine32.inc
.data
a REAL10 ?
b REAL10 ?
c REAL10 ?

.code
quadratic PROC
fld c
fld a
fld b
fmul
exit
quadratic ENDP
END MAIN
