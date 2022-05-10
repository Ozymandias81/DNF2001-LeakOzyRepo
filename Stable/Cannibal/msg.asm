TITLE msg.asm
		.586P
		.model FLAT

EXTRN __msg_string_off:DWORD
EXTRN __msg_float_off:DWORD
EXTRN __msg_int_off:DWORD
EXTRN __msg_token_size:DWORD

_TEXT	SEGMENT
		.code

; save ebp,edi,esi,ebx

; 20 imp_func
; 16 argv
; 12 argc
; 8  pstr
; 4	 ret
; 0  ebp
; -4 esi
; -8 edi

PUBLIC _msg_call_stack
_msg_call_stack PROC NEAR
; param offsets
inmsg		= 8
intarget	= 12
pstr		= 16
argc		= 20
argv		= 24
imp_func	= 28

	push	ebp
	mov		ebp,esp
	push	esi
	push	edi
	push	ebx

r_count TEXTEQU	<ecx>
r_pstr	TEXTEQU	<edi>
r_token	TEXTEQU	<esi>
r_size	TEXTEQU	<ebx>

	mov		r_count,dword ptr [ebp+argc]
	mov		r_token,dword ptr [ebp+argv]
	mov		r_pstr,dword ptr [ebp+pstr]
	mov		r_size,dword ptr[__msg_token_size]
	
	xor		ebp,ebp
	add		r_token,r_size
	
build_loop:
	dec		r_count
	jz		done
	movzx	eax,byte ptr[r_pstr]
	sub		r_token,r_size
	dec		r_pstr

r_off	TEXTEQU	<edx>
	add		ebp,4
	cmp		eax,'f'
	mov		r_off,dword ptr[__msg_float_off]
	jz		push_float
	cmp		eax,'i'
	mov		r_off,dword ptr[__msg_int_off]
	jz		push_int
	cmp		eax,'p'
	mov		r_off,dword ptr[__msg_int_off]
	jz		push_int
	cmp		eax,'s'
	mov		r_off,dword ptr[__msg_string_off]
	jz		push_string
	; fall through case, fix up stack adjustment value, since we didn't push
	sub		ebp,4
	jmp		build_loop

push_int:
	mov		eax,dword ptr[r_token+r_off]
	push	eax
	jmp		build_loop
push_float:
	mov		eax,dword ptr[r_token+r_off]
	push	eax
	jmp		build_loop
push_string:
	lea		eax,dword ptr[r_token+r_off]
	push	eax
	jmp		build_loop
	
; parameter list ready
r_func	TEXTEQU	<edx>
done:
	lea		ebp,dword ptr[esp+ebp+12]
	mov		ecx,dword ptr[ebp+inmsg]
	mov		edx,dword ptr[ebp+intarget]
	push	ecx
	mov		eax,dword ptr[ebp+imp_func]
	push	edx
	
	call	eax
	; fix up stack
	sub		ebp,12
	mov		esp,ebp
	
	pop	ebx
	pop	edi
	pop	esi
	pop	ebp
	ret
_msg_call_stack ENDP

END