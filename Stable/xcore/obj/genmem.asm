; Listing generated by Microsoft (R) Optimizing Compiler Version 12.00.8943.0 

	TITLE	C:\duke4\xcore\genmem.cpp
	.386P
include listing.inc
if @Version gt 510
.model FLAT
else
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT DWORD USE32 PUBLIC 'BSS'
_BSS	ENDS
$$SYMBOLS	SEGMENT BYTE USE32 'DEBSYM'
$$SYMBOLS	ENDS
$$TYPES	SEGMENT BYTE USE32 'DEBTYP'
$$TYPES	ENDS
_TLS	SEGMENT DWORD USE32 PUBLIC 'TLS'
_TLS	ENDS
FLAT	GROUP _DATA, CONST, _BSS
	ASSUME	CS: FLAT, DS: FLAT, SS: FLAT
endif

INCLUDELIB MSVCRT
INCLUDELIB OLDNAMES

PUBLIC	_main
EXTRN	__imp___iob:BYTE
EXTRN	__imp__fflush:NEAR
EXTRN	__imp__printf:NEAR
_DATA	SEGMENT
$SG896	DB	'%%define PAGE_SIZE_OFF %d', 0aH, 00H
	ORG $+1
$SG897	DB	'%%define ALLOC_OFF %d', 0aH, 00H
	ORG $+1
$SG900	DB	'%%define BLOCK_NEXT_OFF %d', 0aH, 00H
; Function compile flags: /Ogty
; File C:\duke4\xcore\genmem.cpp
_DATA	ENDS
_TEXT	SEGMENT
_main	PROC NEAR

; 6    : {

	push	esi

; 7    : 	U32 page_size=oof(CMemManage,page_size);
; 8    : 	U32 small_alloc=oof(CMemManage,small_allocs);
; 9    : 
; 10   : 	printf("%%define PAGE_SIZE_OFF %d\n",page_size);

	mov	esi, DWORD PTR __imp__printf
	push	40					; 00000028H
	push	OFFSET FLAT:$SG896
	call	esi

; 11   : 	printf("%%define ALLOC_OFF %d\n",small_alloc);

	push	0
	push	OFFSET FLAT:$SG897
	call	esi

; 12   : 	printf("%%define BLOCK_NEXT_OFF %d\n",oof(CVirtualBlock,next));

	push	8
	push	OFFSET FLAT:$SG900
	call	esi

; 13   : 
; 14   : 	fflush(stdout);

	mov	eax, DWORD PTR __imp___iob
	add	eax, 32					; 00000020H
	push	eax
	call	DWORD PTR __imp__fflush
	add	esp, 28					; 0000001cH

; 15   : 	return 0;

	xor	eax, eax
	pop	esi

; 16   : }

	ret	0
_main	ENDP
_TEXT	ENDS
END
