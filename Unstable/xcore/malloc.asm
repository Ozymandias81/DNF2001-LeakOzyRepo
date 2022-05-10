section .text

global @_xalloc@4
global @_xrealloc@8
global @_xfree@4
global __sleep

extern __mem_lock
extern __gmalloc
extern ?alloc_large@CMemManage@@QAEPAXK@Z
extern ?alloc_huge@CMemManage@@QAEPAXK@Z
extern ?free@CMemManage@@AAEXPAX@Z

%include "memoff.inc"

; uses pools of size 8,16,32,64,96,128,192,256
align 16
@_xalloc@4:
	mov		ebp,esp
	push	ebp
	push	ebx
	push	edi

	bts		dword[__mem_lock],1
	mov		eax,@_xalloc@4
	jc		NEAR __sleep

	mov		eax,256
	cmp		ecx,eax
	jg		.xalloc_large

	push	dword 0x40201008
	push	dword 0x00c08060
	
	lea		edx,[esp+4]
	xor		ebx,ebx

.keep_looking:
	movzx	eax,byte[edx+ebx]
	inc		ebx
	cmp		eax,ecx
	jl		.keep_looking

	dec		ebx
	mov		edx,ebx
	and		ebx,8
	shl		ebx,3
	or		eax,ebx

	; eax==block size
	; ecx==size requested

	mov		ecx,dword[__gmalloc]
	push	ecx
	mov		edi,dword[ecx+edx*4+ALLOC_OFF]
	call	edi
	add		esp,12

.exit:
	and		dword[__mem_lock],~1
	pop		edi
	pop		ebx
	pop		ebp
	ret

.xalloc_large:
	mov		edx,dword[__gmalloc]
	cmp		ecx,dword[edx+PAGE_SIZE_OFF]
	jge		.xalloc_huge

	push	ecx
	mov		ecx,dword[__gmalloc]
	call	?alloc_large@CMemManage@@QAEPAXK@Z
	add		esp,4

	jmp		.exit

.xalloc_huge:
	push	ecx
	mov		ecx,dword[__gmalloc]
	call	?alloc_huge@CMemManage@@QAEPAXK@Z
	add		esp,4

	jmp		.exit

align	16
@_xrealloc@8:
	bts		dword[__mem_lock],1
	mov		eax,@_xrealloc@8
	jc		__sleep
	
	mov		ecx,dword[__gmalloc]

	and		dword[__mem_lock],~1
	ret

align	16
@_xalloc_heap@8:
	int	3
	ret

align	16
@_xfree@4:
	bts		dword[__mem_lock],1
	mov		eax,@_xfree@4
	jc		__sleep
	
	push	ecx
	mov		ecx,dword[__gmalloc]
	call	?free@CMemManage@@AAEXPAX@Z

	and		dword[__mem_lock],~1
	ret

__sleep:
	xor		eax,eax
	push	eax
	ret

__mem_bitch:
	ret

__mem_throw:
	ret

__mem_fatal:
	ret

END
