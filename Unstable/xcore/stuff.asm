section .text

global @fstrlen@4
global @_bsf@4
global _xxx_printf
global _begin_tick
global _begin_tick
global _end_tick

;global object
extern ?_global@@3PAVXGlobal@@A
;XGlobal::printf()
extern ?printf@XGlobal@@QAAXKPBDZZ
extern _xxx_printf_noglobal

%define _global ?_global@@3PAVXGlobal@@A
%define _global_printf ?printf@XGlobal@@QAAXKPBDZZ

align 16
@fstrlen@4:
	xor		eax,eax

next:
	movzx	edx,byte[ecx]
	inc		ecx
	inc		eax
	test	edx,edx
	jnz		next

	dec		eax
	ret

align 16
@_bsf@4:
	xor      eax,eax
	bsf      eax,ecx
	ret

align 16
@_bsfs@4:
	mov      edx,ecx
	xor      ecx,ecx

	bsf      ecx,dword[edx]
	mov      eax,1

	shl      eax,cl

	not      eax

	and      dword[edx],eax
	mov      eax,ecx

	ret

align 16
_xxx_printf:
	mov		ecx,_global
	test	ecx,ecx
	jz		print_no_global
	jmp		_global_printf

print_no_global:
	jmp		_xxx_printf_noglobal
	ret

align	16
_begin_tick:
	mov		ecx,dword[esp + 4]

	rdtsc

	mov		dword[ecx],eax
	mov		dword[ecx+4],edx

	ret

align	16
_end_tick:
%define TICK_FUNC_CLOCKS 20
	mov		ecx,dword[esp + 4]

	rdtsc

	sub		eax,TICK_FUNC_CLOCKS
	sbb		edx,0

	mov		dword[ecx],eax
	mov		dword[ecx+4],edx

	ret

END
