;
;    INTEL CORPORATION PROPRIETARY INFORMATION
;
;    This software is supplied under the terms of a license
;    agreement or nondisclosure agreement with Intel Corporation
;    and may not be copied or disclosed except in accordance with
;    the terms of that agreement.
;    Copyright (c) 1995  Intel Corporation.
;
;

; SubBandSynthesis_a function gets 32 input 16 bit +/-1  scaled by 32768
; fixed point values
; The second parameter is the channel. For Stereo it should be called once with
; 0 for channal 0 and again with 1 for channal 1, 3 times for every group,
; times the number of groups in a frame.
; For mono the second parameter should be 0.
; the third parameter is a pointer for 32 results of the synthesis.
; the last parameter is a pointer to the V buffer
;
;int SubBandSynthesis_a (bandPtr, channel, samples, V)
;short *bandPtr;
;int channel;
;short *samples;
;udword *V;
;
.586
.MMX
.MODEL FLAT

MMWORD	TEXTEQU	<QWORD>


ASSUME ds:FLAT, cs:FLAT, ss:FLAT

_DATA SEGMENT PARA PUBLIC USE32  'DATA'
_DATA ENDS

_TEXT SEGMENT PARA PUBLIC USE32  'CODE'

	ALIGN     16
	PUBLIC   _SubBandSynthesis_a
_SubBandSynthesis_a	PROC NEAR
		mov		  eax, DWORD PTR 16[esp]	; V
		nop

		mov       edx, DWORD PTR 8[esp]		; channel
        mov       ecx, DWORD PTR 4[esp]		; source for _idct()

        push      ebp
        push      ebx

        mov       ebx, DWORD PTR shift[edx*4]
        mov       ebp, DWORD PTR 4096[eax]	; bufOffset is stored at end of V

        shl       edx, 11
        add       ebx, ebp

        push      edi
        push      esi

        and		  ebx, 1023					; ebx=bufOffset for _sbs (idct doesn't use ebx)
		lea		  ebp, DWORD PTR [eax+edx]	; ebp=_buf_addr  for _sbs (idct doesn't use ebp)
;!!!!
		mov	      DWORD PTR 4096[eax],ebx   ; INSERT this instruction to empty slot !!!!
		nop

;*************************************************************************************************
;------------------------------------------------------------------------------------------------
;       inlined _idct function. The C code. 
;------------------------------------------------------------------------------------------------
;short int_even8[8][8] = {
;   { 16384,  16384,  16384,  16384,  16384,  16384,  16384,  16384 }, 
;   { 16069,  13622,   9102,   3196,  -3196,  -9102, -13622, -16069 }, 
;   { 15136,   6269,  -6269, -15136, -15136,  -6269,   6269,  15136 }, 
;   { 13622,  -3196, -16069,  -9102,   9102,  16069,   3196, -13622 }, 
;   { 11585, -11585, -11585,  11585,  11585, -11585, -11585,  11585 }, 
;   {  9102, -16069,   3196,  13622, -13622,  -3196,  16069,  -9102 }, 
;   {  6269, -15136,  15136,  -6269,  -6269,  15136, -15136,   6269 }, 
;   {  3196,  -9102,  13622, -16069,  16069, -13622,   9102,  -3196 }, 
; };
;
;short int_odd8[8][8] = {
;   { 16305,  15678,  14449,  12665,  10393,   7723,   4756,   1605 }, 
;   { 15678,  10393,   1605,  -7723, -14449, -16305, -12665,  -4756 }, 
;   { 14449,   1605, -12665, -15678,  -4756,  10393,  16305,   7723 }, 
;   { 12665,  -7723, -15678,   1605,  16305,   4756, -14449, -10393 }, 
;   { 10393, -14449,  -4756,  16305,  -1605, -15678,   7723,  12665 }, 
;   {  7723, -16305,  10393,   4756, -15678,  12665,   1605, -14449 }, 
;   {  4756, -12665,  16305, -14449,   7723,   1605, -10393,  15678 }, 
;   {  1605,  -4756,   7723, -10393,  12665, -14449,  15678, -16305 }, 
; };
;
;short int_odd16[16][16] = {
;   { 16364,  16206,  15892,  15426,  14810,  14053,  13159,  12139,  11002,   9759,   8423,   7005,   5519,   3980,   2404,    803 }, 
;   { 16206,  14810,  12139,   8423,   3980,   -803,  -5519,  -9759, -13159, -15426, -16364, -15892, -14053, -11002,  -7005,  -2404 }, 
;   { 15892,  12139,   5519,  -2404,  -9759, -14810, -16364, -14053,  -8423,   -803,   7005,  13159,  16206,  15426,  11002,   3980 }, 
;   { 15426,   8423,  -2404, -12139, -16364, -13159,  -3980,   7005,  14810,  15892,   9759,   -803, -11002, -16206, -14053,  -5519 }, 
;   { 14810,   3980,  -9759, -16364, -11002,   2404,  14053,  15426,   5519,  -8423, -16206, -12139,    803,  13159,  15892,   7005 }, 
;   { 14053,   -803, -14810, -13159,   2404,  15426,  12139,  -3980, -15892, -11002,   5519,  16206,   9759,  -7005, -16364,  -8423 }, 
;   { 13159,  -5519, -16364,  -3980,  14053,  12139,  -7005, -16206,  -2404,  14810,  11002,  -8423, -15892,   -803,  15426,   9759 }, 
;   { 12139,  -9759, -14053,   7005,  15426,  -3980, -16206,    803,  16364,   2404, -15892,  -5519,  14810,   8423, -13159, -11002 }, 
;   { 11002, -13159,  -8423,  14810,   5519, -15892,  -2404,  16364,   -803, -16206,   3980,  15426,  -7005, -14053,   9759,  12139 }, 
;   {  9759, -15426,   -803,  15892,  -8423, -11002,  14810,   2404, -16206,   7005,  12139, -14053,  -3980,  16364,  -5519, -13159 }, 
;   {  8423, -16364,   7005,   9759, -16206,   5519,  11002, -15892,   3980,  12139, -15426,   2404,  13159, -14810,    803,  14053 }, 
;   {  7005, -15892,  13159,   -803, -12139,  16206,  -8423,  -5519,  15426, -14053,   2404,  11002, -16364,   9759,   3980, -14810 }, 
;   {  5519, -14053,  16206, -11002,    803,   9759, -15892,  14810,  -7005,  -3980,  13159, -16364,  12139,  -2404,  -8423,  15426 }, 
;   {  3980, -11002,  15426, -16206,  13159,  -7005,   -803,   8423, -14053,  16364, -14810,   9759,  -2404,  -5519,  12139, -15892 }, 
;   {  2404,  -7005,  11002, -14053,  15892, -16364,  15426, -13159,   9759,  -5519,    803,   3980,  -8423,  12139, -14810,  16206 },
;   {   803,  -2404,   3980,  -5519,   7005,  -8423,   9759, -11002,  12139, -13159,  14053, -14810,  15426, -15892,  16206, -16364 },
;};
;void int_dct32(short *in, short *out)
; // integer implimentation of Lee's DCT algorithm - decimation to 8,8, and 16 DCT.
; {
;    short even[16], odd[16], ee[8], eo[8];
;    int i,j;
; 
;    // input butterfly
;    for(i=0; i<16; i++) { // 32->16 butterfly
;       even[i]=in[i]+in[31-i];
;       odd[i] =in[i]-in[31-i];
;    }
; 
;    // == even part ==
;    for(i=0; i<8; i++) { // 16->8 butterfly
;       ee[i] = even[i]+even[15-i];
;       eo[i] = even[i]-even[15-i];
;    }
;    // even - even part
; 
;    for(i=0; i<8; i++) {
;       long s=0;
;       for(j=0; j<8; j++)
;          s += (long)int_even8[i][j]*ee[j] ;  // pmad with 32 bit additions
;       out[i*4] = (int)(s>>14);
;    }
; 
;    // even - odd part
;    for(i=0; i<8; i++) {
;       long s=0;
;       for(j=0; j<8; j++)
;          s += (long)int_odd8[i][j]*eo[j] ;  // pmad with 32 bit additions
;       out[i*4+2] = (short)(s>>14);
;    }
; 
;    // == odd part ==
;    for(i=0; i<16; i++) {
;       long s=0;
;       for(j=0; j<16; j++)
;          s += (long)int_odd16[i][j]*odd[j] ;  // pmad with 32 bit additions
;       out[i*2+1] = (short)(s>>14);
;    }
; }
; 
;idct() {
;   short  new_result1[32];
;   short  new_result[64];
;   
;	int_dct32(fix_sampl,new_result1);
;	for (i=0,j=32; i<16; i++,j--) {
;  		new_result[i   ]=(new_result1)[i+16]; 
;  		new_result[i+16]=-new_result1[j];
;  		new_result[i+32]=-new_result1[j-16];
;  		new_result[i+48]=-new_result1[i];
;   }
;   new_result[16]=0;
;}


; we store our temporary results in result[] array.
_result			equ	[edx]
_ee				equ	_result
_eo				equ	_result+16
_odd_res        equ	_result+32
_odd	        equ	_result+64
_offset_to_odd_vector	equ	32	; (_odd - _odd_res) , enables to use one reg, to point to two vectors

; first arg is fix samples
; second is pointer to result array

;----------------------------------------------------------------
;Our task now, is to prepare 3 vectors ee[], eo[] and odd[],
;and then multiply them by matrixes, and mix results of multiplication
;----------------------------------------------------------------

;ee[0]=in[0]+in[31]+in[15]+in[16]	;eo[0]=in[0]+in[31]-(in[15]+in[16])
;ee[1]=in[1]+in[30]+in[14]+in[17]	;eo[1]=in[1]+in[30]-(in[14]+in[17])
;ee[2]=in[2]+in[29]+in[13]+in[18]	;eo[2]=in[2]+in[29]-(in[13]+in[18])
;ee[3]=in[3]+in[28]+in[12]+in[19]	;eo[3]=in[3]+in[28]-(in[12]+in[19])

;odd[0] =in[0 ]-in[31] ;odd[1 ]=in[1 ]-in[30] ;odd[2 ]=in[2 ]-in[29] ;odd[3 ]=in[3 ]-in[28]
;odd[4] =in[4 ]-in[27] ;odd[5 ]=in[5 ]-in[26] ;odd[6 ]=in[6 ]-in[25] ;odd[7 ]=in[7 ]-in[24]
;odd[8] =in[8 ]-in[23] ;odd[9 ]=in[9 ]-in[22] ;odd[10]=in[10]-in[21] ;odd[11]=in[11]-in[20]
;odd[12]=in[12]-in[19] ;odd[13]=in[13]-in[18] ;odd[14]=in[14]-in[17] ;odd[15]=in[15]-in[16]

; start prepare ee[], eo[], odd[]

;	ecx points to source (pointer to fix samples)
;	edx will point (after lea instruction)	to  result array

	movq	mm0,[ecx+56]	;1) 31 30 29 28

	movq	mm6,[ecx+24]	;1) 15 14 13 12
	punpckhdq mm0,mm0	;1) 31 30 31 30

	movq	mm1,[ecx+56] ;1) 31 30 29 28
	psrlq	mm0,16		;1)  0 31 30 31

	punpckldq mm1,mm1	;1) 29 28 29 28
	movq	mm7,mm6		;1) 15 14 13 12

	lea	edx, [2*ebx+ebp]		; edx= dest for _idct()
	psrlq	mm1,16		;1)  0 29 28 29

	mov	edi, DWORD PTR 28[esp]		; result pointer for _sbs()
	punpckldq mm0,mm1	;1) 28 29 30 31  (!)

	punpckldq mm7,mm7	;1) 13 12 13 12
	movq	mm5,mm0		;odd0) 28 29 30 31  (!) 

	paddsw	mm0,[ecx]	;1) 28+3 29+2 30+1 31+0
	psrlq	mm7,16		;1)  0 13 12 13

	punpckhdq mm6,mm6	;1) 15 14 15 14
	movq	mm1,mm0		;1) 28+3 29+2 30+1 31+0

	psubsw	mm5,[ecx]	;odd0)	28-3 29-2 30-1 31-0
	psrlq	mm6,16		;1)  0 15 14 15

	movq	mm2,[ecx+48]	;2) 27 26 25 24
	punpckldq mm6,mm7	;1) 12 13 14 15  (!)

	movq	_odd,mm5	;odd0) save -odd[0..3]
	movq	mm5,mm6		;odd2) 12 13 14 15  (!)

	paddsw	mm6,[ecx+32]	;1) 12+19 13+18 14+17 15+16
	movq	mm3,mm2		;2) 27 26 25 24

	psubsw	mm5,[ecx+32]	;odd2) 12-19 13-18 14-17 13-16
	paddsw	mm0,mm6		;1) ee3 ee2 ee1 ee0

	movq	mm4,[ecx+16]	;2) 11 10  9  8
	punpckhdq mm2,mm2	;2) 27 26 27 26

	movq	_odd+3*8,mm5;odd2) save odd[15..12]
	psrlq	mm2,16		;2)  0 27 26 27

	psubsw	mm1,mm6		;1) eo3 eo2 eo1 eo0
	punpckldq mm3,mm3	;2) 25 24 25 24

	movq	mm5,mm4		;2)
	psrlq	mm3,16		;2)  0 25 24 25

	movq	MMWORD PTR _eo,mm1 ;1)
	punpckldq mm2,mm3	;2) 24 25 26 27 (!)
	
	movq	mm6,mm2		;odd1) 24 25 26 27 (!)
	punpckhdq mm4,mm4	;2) 11 10 11 10

	psubsw	mm6,[ecx+8] ;odd1) 24-7 25-6 26-5 27-4 
	psrlq	mm4,16		;2)  0 11 10 11
	
	paddsw	mm2,[ecx+8]	;2) 7+24 6+25 5+26 4+27
	punpckldq mm5,mm5	;2)  9  8  9  8 

	movq	_odd+1*8,mm6;odd1) save -odd[4..7]
	psrlq	mm5,16		;2)  0  9  8  9

	movq	mm3,mm2		;2) 7+24 6+25 5+26 4+27
	punpckldq mm4,mm5	;2)  8  9 10 11	 (!)

	movq	mm5,[ecx+40]	; we need it to perform some instruction in V-pipe
	movq	mm6,mm4		;odd3) 8  9 10 11	 (!)

	paddsw	mm4,mm5		;  [ecx+40];2) 8+23 9+22 10+21 11+20	
	psubsw	mm6,mm5		;  [ecx+40];odd3) 8-23 9-22 10-21 11-20

	psubsw	mm3,mm4		;2) eo7 eo6 eo5 eo4
	lea	ecx,[_ee]	; prepare ecx for 8x8 matrix multiplication (even-even)

	movq	_odd+2*8,mm6;odd3) save odd[11..8]
	movq	mm1,mm0		; prepare argument for 8x8 matrix multiplication
	
	movq	MMWORD PTR _eo+8,mm3
	paddsw	mm2,mm4		;2) ee7 ee6 ee5 ee4 ; we nead result in register for Mtrx. mult

 ;	mm0 contains ee[0]..ee[4] components
 ;	mm2 contains ee[5]..ee[7] components
 ;	Let's multiply ee[] by 8x8 matrix 
	

;-----------------------------------------------------------------
; even-even	(calculate even-even components of result signal)
;-----------------------------------------------------------------

	lea	eax,[even_even8x8]
	call	_8x8MxV_mmx

; let's finish _8x8MxV_mmx() function here, and save 1 cycle
	paddd	mm2,mm1
	paddd	mm6,mm7

	paddd   mm3,mm2
	psrad	mm6,14

; store last result of "even_even" here to save 2 cycles, and prepare arguments for "even_odd"
	movq	mm0,_eo			; 0 1 2 3 elements of input vector ; from even-odd
    psrad	mm3,14	

	movq	mm2,_eo+8		; 4 5 6 7 elements of input vector
	packssdw mm3,mm6		; pack result of iteration 3 & 4 ;( from even-even)

	lea		eax,[even_odd8x8]
  	lea 	esi,[odd16x16]	   	; pointer to matrix for next(NOT THIS) odd 16x16 multiplication

	movq	MMWORD PTR 8[ecx],mm3	; store result of iteration 3 & 4 of even-even
	movq	mm1,mm0

;-----------------------------------------------------------------
; even-odd (calculate even-odd components of result signal)
;-----------------------------------------------------------------
	lea	ecx,[_eo]		; output array
	call	_8x8MxV_mmx

; let's finish _8x8MxV_mmx() function here, and save 1 cycle
	paddd	mm2,mm1
	paddd	mm6,mm7

	paddd   mm3,mm2
	psrad	mm6,14

; store last result of "even_odd" here to save 2 cycles, and prepare arguments for "odd"

	lea	eax, [_odd_res]		; pointer to the result vector
 	mov	ecx, -4

   	movq	mm4,0[esi]		; First 4 from Matrix
    psrad	mm3,14	


;-----------------------------------------------------------------
; ODD COMPONENTS: to receive them we should multiply vector by 16x16 matrix
;---------------------------------------------------------------
;	inlinied  multiplication of 16x16 matrix by vector
;---------------------------------------------------------------

  	movq	 mm7,0[eax+_offset_to_odd_vector]		; 0 1 2 3 from input vector
	packssdw mm3,mm6		; pack result of iteration 3 & 4 ov 8x8 matrix mult

; mm3 contains value of eo[4..8]. Let's use layout of eo[] and odd[] arrays, and save mm3 in first
; iteration of 16x16 matrix multiplication.

four_lines:
   	movq	 mm5,8[esi]		; second 4 from Matrix
    pmaddwd	 mm4,mm7		; mm4 < first accumulator

	movq	 mmword ptr 24[8*ecx+eax], mm3     ; store result of previous iteration, or eo[4..7](in first iteration)

   	movq	 mm6,16[esi] 
   	pmaddwd	 mm5, mm7		; mm5 <  accumulator 2 result

	movq	 mm0, 8[eax+_offset_to_odd_vector]
   	pmaddwd	 mm6, mm7		; mm6 <  accumulator 3 result

   	pmaddwd	 mm7, 24[esi]		; mm7 <  accumulator 4 result
	movq	 mm1, mm0

	pmaddwd	 mm1, 32[esi]		; 4 5 6 7 from vector * first line
   	movq	 mm2, mm0

	pmaddwd	 mm2, 40[esi]		; 4 5 6 7 from vector * second line
   	movq	 mm3, mm0

	pmaddwd	 mm3, 48[esi]		; 4 5 6 7 from vector * 3'rd line

	pmaddwd	 mm0, 56[esi]		; 4 5 6 7 from vector * 4'th line
	paddd	 mm4, mm1		; accumulator 0

  	movq	 mm1,16[eax+_offset_to_odd_vector]		; read 8 9 10 11 from vector
	paddd	 mm5, mm2		; accumulator 1

   	movq	 mm2, 64[esi]		; read 
   	paddd	 mm6, mm3		; accumulator 2

	movq	 mm3, 72[esi]
   	pmaddwd	 mm2, mm1

	paddd	 mm7, mm0		;  accumulator 3
   	pmaddwd	 mm3, mm1

  	movq	 mm0,80[esi]

	pmaddwd	 mm0, mm1
	paddd	 mm4, mm2

  	pmaddwd	 mm1, 88[esi]		; last time use the vector for result
	paddd	 mm5, mm3

  	movq	 mm2,24[eax+_offset_to_odd_vector]

   	movq	 mm3, 96[esi]
   	paddd	 mm6, mm0

	movq	 mm0, 104[esi]
	paddd	 mm7, mm1

	movq	 mm1, 112[esi]
   	pmaddwd	 mm3, mm2

	pmaddwd  mm0, mm2
	
	pmaddwd  mm1, mm2
	
	pmaddwd  mm2, 120[esi]
	paddd	 mm4, mm3
	
	paddd    mm5, mm0
	movq	 mm3, mm4
	
	paddd    mm6, mm1
	punpckldq mm3, mm5
	
	paddd    mm2, mm7 
	punpckhdq mm4, mm5

	paddd	 mm3, mm4
	movq	 mm1, mm6

  	punpckldq mm1, mm2
	add	 esi, 128

  	movq	 mm7,0[eax+_offset_to_odd_vector]
	punpckhdq mm6, mm2

	psrad	 mm3, 14
	paddd	 mm1, mm6

	psrad	 mm1, 14
	inc 	ecx

    movq	 mm4,0[esi]
	packssdw mm3, mm1

	jnz	 four_lines


; -------------------------finished multiplicaton of matrix 16x16-----------


;-----------------------------------------------------------------
; now it's time to merge even-even[8], even-odd[8] and odd[16] arrays
;-------------------------------------------------------------
;----- first iteration
; in first iteration we receive result[40]...result[55] components
; layout in registers before move to memory is like this:
; 40..43: [odd2 eo1 odd3 ee2] (in comments it's called "last")
; 44..47: [odd0 eo0 odd1 ee1]
; 48..51: [odd1 eo0 odd0 ee0]
; 52..55: [odd3 eo1 odd2 ee1]

; we may put this movq into 16x16 matrix mult loop, after psrad, and save 1 cycle
	movq		mm0,_ee		; ee3 ee2 ee1 ee0
	
	movq		mm4,_odd_res; odd3 odd2 odd1 odd0
	movq		mm2,mm0		;44-47; ee3 ee2 ee1 ee0

	punpcklwd	mm0,_eo		;48-55 eo1 ee1 eo0 ee0
	movq		mm7,mm2		; last; ee3 ee2 ee1 ee0
		
	movq		mm6,mm0		;52-55; eo1 ee1 eo0 ee0
	punpcklwd	mm0,mm4		;48-51; ODD1 EO0 ODD0 EE0; READY
	
	movq		mm5,_eo		;44-47; eo3 eo2 eo1 eo0
	punpckhwd 	mm6,mm4		;52-55; ODD3 EO1 ODD2 EE1; READY

	movq	 mmword ptr 24[8*ecx+eax], mm3     ; last write from 16x16 matrix mult
	punpcklwd	mm2,mm4		;44-47; ODD1 EE1 odd0 ee0
 
	movq	_result+96,mm0		; write res[48..51]
	punpcklwd	mm5,mm4		;44-47; odd1 eo1 ODD0 EO0

	movq	_result+104,mm6		; write res[52..55]
 	punpckhwd	mm6,mm4		; last; odd3 odd3 ODD2 EO1

	movq		mm0,_ee		;     ; ee3 ee2 ee1 ee0  ; from second iteration
	punpckhwd	mm7,mm6		; last; odd3 ee3 ODD3 EE2

	pand		mm7,zzzzoooo	; last; 00 00 ODD3 EE2
	psrlq		mm2,32		;44-47; 0    0   ODD1 EE1

	psllq		mm5,32		;44-47; ODD0 EO0 0 0 
	movq		mm4,mm0		;     ; ee3 ee2 ee1 ee0  ; from second iteration

	punpckhwd	mm0,_eo		;56-63; eo3 ee3 eo2 ee2  ; from second iteration
	por 		mm5,mm2		;44-47; odd0 eo0 odd1 ee1

	psllq		mm6,32		; last;	ODD2 EO1 00 00
	movq		mm2,mm0		;60-63; eo3 ee3 eo2 ee2  ; from second iteration

	punpcklwd	mm0,_odd_res+8	;56-59; odd5 eo2 odd4 ee2; READY from second iteration
	movq		mm1,mm2		;     ; eo3 ee3 eo2 ee2  ; from second iteration

;-- second iteration
; in this iteration we receive result[32..39] and result[56..63] components
; layout in registers before move to memory is like this:
; 32..35: [odd6 eo3 odd7 ee4]
; 36..39: [odd4 eo2 odd5 ee3]
; 56..59: [odd5 eo2 odd4 ee2]
; 60..63: [odd7 eo3 odd6 ee3]

	punpckhwd   mm2,_odd_res+8	;60-63; odd7 eo3 odd6 ee3; READY
	por			mm7,mm6		; last; ODD2 EO1 ODD3 EE2; READY from FIRST iteration
	
	movq	_result+88,mm5	        ; write res[44..47]  ; from first iteration
	punpckhwd	mm4,mm0		;36-39; ODD5 EE3 eo3 ee2

	movq	_result+112,mm0	        ; write res[56-59]
	punpcklwd	mm1,mm0		;36-39; ODD4 EO2 ee2 ee2

	pand		mm1,oooozzzz    ;36-39; ODD4 EO2 00  00
	psrlq		mm4,32		;36-39; 00 00 ODD5 EE3

	movq		mm3,_ee+8	;32-35 00 00 ee5 ee4
	movq		mm5,mm2		;32-35;	odd7 EO3 odd6 ee3;

	movq	_result+80,mm7		; write res[40..43]  ; from first iteration
	movq		mm0,mm3		; prepare ee[4..7] for NEXT iteration
	
	punpckhwd	mm5,_odd_res+8 ; odd7 odd7 ODD6 EO3
; EMPTY slot

	movq	_result+120,mm2		; write res[60-63]
	por 		mm4,mm1		;36-39; ODD4 EO2 ODD5 EE3; READY
	
	psrlq		mm2,48		;32-35 00 00 00 odd7
	movq		mm7,mm0		;28-31; ee7 ee6 ee5 ee4; FROM THIRD ITERATION

	movq	_result+ 72,mm4		; write res[36-39]
	punpcklwd	mm3,mm2		;32-35 00 ee5 ODD7 EE4

	pand		mm3,zzzzoooo	;32-35 00 00 ODD7 EE4
	psllq		mm5,32			;32-35; ODD6 EO3 00 00

	punpcklwd	mm0,_eo+8	;0-7;   eo5 ee5 eo4 ee4 ; from THIRD iteration
	por 		mm5,mm3

; ----- third iteration
; in this iteration we receive result[0..7] and result[24..31] components
; layout in registers before move to memory is like this:
;  0.. 3: [-odd9  -eo4 -odd8  -ee4]
;  4.. 7: [-odd11 -eo5 -odd10 -ee5]
; 24..27: [ odd10  eo5  odd11  ee6]
; 28..31: [ odd8   eo4  odd9   ee5]
	
	movq		mm3,_odd_res+16 ; odd11 odd10 odd9 odd8
	movq		mm1,mm7		;24-27; ee7 ee6 ee5 ee4

	movq		mm4,mm0		;0-7; eo5 ee5 eo4 ee4 ; even components
	punpcklwd	mm0,mm3		; ODD9  EO4 ODD8 EE4; - before mult. by -1

	pxor		mm2,mm2
	pxor		mm6,mm6

	psubsw		mm2,mm0		; -ODD9  -EO4 -ODD8 -EE4; READY
	punpckhwd	mm4,mm3		; odd11 eo5 odd10 ee5

	movq		mm0,_eo+8	;28-31; eo7 eo6 eo5 eo4
	punpcklwd	mm7,mm3		;28-31; ODD9 EE5 odd8 ee4

	psubsw		mm6,mm4		; -ODD11 -EO5 -ODD10 -EE5; READY
	psrlq		mm7,32		;28-31; 00 00 ODD9 EE5

	movq	_result+ 64,mm5		; write res[32-35] ; from SECOND iteration
	punpcklwd	mm0,mm3		;28-31;odd9 eo5 ODD8 EO4

	movq	_result,mm2
	psllq		mm0,32		;28-31; ODD8 EO4 00 00

	punpckhwd	mm4,_odd_res+16 ;odd11 odd11 ODD10 EO5
	por 		mm7,mm0		;28-31; ODD8 EO4 ODD9 EE5; READY

	movq		mm0,_ee+8	; ee7 ee6 ee5 ee4 ; from FOURTH iteration
	punpckhwd	mm1,mm4		;24-27; odd11 ee7 ODD11 EE6

	pand		mm1,zzzzoooo	;24-27; 00 00 ODD11 EE6	
	psllq		mm4,32		;24-27; ODD10 EO5 00 00

	movq	_result+8,mm6
	por 		mm4,mm1		;24-27; ODD10 EO5 ODD11 EE6; READY

	movq		mm3,_odd_res+24 ; odd15 odd14 odd13 odd12
	movq		mm6,mm0		; ee7 ee6 ee5 ee4 ; from FOURTH iteration
	
; ---------- fourth iteration
; in this iteration we receive result[8..15] and result[16..23] components
; layout in registers before move to memory is like this:
;  8..11: [-odd13 -eo6 -odd12 -ee6]
; 12..15: [-odd15 -eo7 -odd14 -ee7]
; 16..19: [ odd14  eo7  odd15   0 ]
; 20..23: [ odd12  eo6  odd13  ee7]

	punpckhwd	mm0,_eo+8	; eo7 ee7 eo6 ee6 ; from FOURTH iteration
	pxor		mm1,mm1		; 0 0 0 0

	movq	_result+56,mm7
	movq		mm2,mm0		; eo7 ee7 eo6 ee6 

	movq		mm5,mm0
	pxor		mm7,mm7		; 0 0 0 0

	movq	_result+48,mm4	; from THIRD iteration
	punpcklwd	mm0,mm3		; odd13 eo6 odd12 ee6

	punpckhwd	mm2,mm3		; odd15 eo7 odd14 ee7
	psubsw		mm1,mm0		; -ODD13 -EO6 -ODD12 -EE6

	psubsw		mm7,mm2		; -ODD15 -EO7 -ODD14 -EE7
	punpcklwd	mm5,mm0		;20-23; ODD12 EO6 ee7 ee6

	pand		mm5,oooozzzz	;20-23
	punpckhwd	mm6,mm0		;20-23; ODD13 EE7 eo6 ee6

	movq	_result+16,mm1
	psrlq		mm6,32		;20-23

	por 		mm6,mm5		;20-23
	punpckhwd	mm2,mm3		;odd15 odd15 ODD14 EO7

	movq	_result+24,mm7
	psrlq		mm3,32

	pand		mm3,zzzzoozz
	psllq		mm2,32		;ODD14 EO7 00 00

	movq	_result+40,mm6
	por 		mm2,mm3	

;-------------------------- end of _idct() ------------------------------------------------------

;*************************************************************************************************
;*************************************************************************************************
;			filtering function
;*************************************************************************************************
;    /*  S(i,j) = D(j+32i) * U(j+32i+((i+1)>>1)*64)  */
;    /*  samples(i,j) = MWindow(j+32i) * bufPtr(j+32i+((i+1)>>1)*64)  */
;
;   	for (j=0; j<32; j+=8) {
;            sum0 = sum1 = sum2 = sum3 = sum4 = sum5 = sum6 = sum7 = 0;
;        	 for (k= bufOffset + j , i=j*2; i<512; i+=64,k+=128) {
;                sum[0] += window[i   ] * buf[channel][(k & 0x3ff)];
;                sum[0] += window[i +1] * buf[channel][(k + 96) & 0x3ff ];
;                sum[1] += window[i +2] * buf[channel][1+(k & 0x3ff)];
;                sum[1] += window[i +3] * buf[channel][1+((k + 96) & 0x3ff) ];
;    
;                sum[2] += window[4 +i] * buf[channel][2+(k & 0x3ff)];
;                sum[2] += window[5 +i] * buf[channel][2+((k + 96) & 0x3ff) ];
;                sum[3] += window[6 +i] * buf[channel][3+(k & 0x3ff)];
;                sum[3] += window[7 +i] * buf[channel][3+((k + 96) & 0x3ff) ];
;    
;                sum[4] += window[8 +i] * buf[channel][4+(k & 0x3ff)];
;                sum[4] += window[9 +i] * buf[channel][4+((k + 96) & 0x3ff) ];
;                sum[5] += window[10+i] * buf[channel][5+(k & 0x3ff)];
;                sum[5] += window[11+i] * buf[channel][5+((k + 96) & 0x3ff) ];
;    
;                sum[6] += window[12+i] * buf[channel][6+(k & 0x3ff)];
;                sum[6] += window[13+i] * buf[channel][6+((k + 96) & 0x3ff) ];
;                sum[7] += window[14+i] * buf[channel][7+(k & 0x3ff)];
;                sum[7] += window[15+i] * buf[channel][7+((k + 96) & 0x3ff) ];
;            }
;       }
;*************************************************************************************************

        pxor      MM4,MM4
        pxor      MM5,MM5

        xor       esi,esi ; esi = j
        pxor      MM6,MM6

	movq	_result+32,mm2		; store last result of _idct() 
        pxor      MM7,MM7

	pxor	  MM2,MM2		; disable first paddd MM7,MM2 in loop1
loop0:
	lea       edx,[ebx+esi]
	lea       ecx,[ebx+esi+96]

	lea       eax,[esi*4-1024]
	and       ecx,3ffH
loop1:
        movq      MM0, MMWORD PTR [EBP+EDX*2]	; read first 4 sub band
	paddd     MM7,MM2			; MM5 +=  sub band 6, 7

        movq      MM2, MMWORD PTR [EBP+ECX*2]	; read second 4 sub band
        movq      MM1,MM0			; make a copy of the first 4

        movq      MM3, MMWORD PTR [8+EBP+EDX*2] ; read sub band [4-7]
        punpcklwd MM0, MM2			; MM0 will have sub band 0 0 1 1

        pmaddwd   MM0,MMWORD PTR window+1024[EAX]	; 32bit values of 0 and 1
        punpckhwd MM1, MM2			; MM1 will have sub band 2 2 3 3

        pmaddwd   MM1,MMWORD PTR window+1024[EAX+8]	; 32bit values of 2 and 3
	movq      MM2,MM3

        punpcklwd MM3, MMWORD PTR [8+EBP+ECX*2]	;MM2; MM3 will have sub band 4 4 5 5

        pmaddwd   MM3,MMWORD PTR window+1024[EAX+16];32bit  values of 4 and 5
        paddd     MM4,MM0			; MM4 += sub band 0, 1

        punpckhwd MM2, MMWORD PTR [8+EBP+ECX*2] ;MM2; MM1 will have sub band  6 6 7 7 
        paddd     MM5,MM1			; MM5 +=  sub band 2, 3

        add       ecx,128			; fix index for second val
        add       edx,128			; fix index for first val
        
        pmaddwd   MM2,MMWORD PTR window+1024[EAX+24];32bit  values of 6 and 7
 	paddd     MM6,MM3			; MM5 +=  sub band 4, 5
        
        and       ecx,3FFH			; cyclic buffer
        and       edx,3FFH			; cyclic buffer

        add       eax,128
        Jl        loop1


	paddd     MM7,MM2			; MM5 +=  sub band 6, 7

	pxor      MM0,MM0 ; Divide by 2**14 and adjust if negative 
	pxor      MM1,MM1 ;    set mask to -1 if nagative result and add

	pcmpgtd   MM0,MM4 ;    to the result before the divide
	pcmpgtd   MM1,MM5 ;  Do it for 4 result registers 

	psrld     MM0,18
	pxor      MM2,MM2

	psrld     MM1,18
	pxor      MM3,MM3

	pcmpgtd   MM2,MM6
	pcmpgtd   MM3,MM7

	psrld     MM2,18
	paddd     MM4,MM0

	psrld     MM3,18
	paddd     MM5,MM1

	paddd     MM6,MM2
	paddd     MM7,MM3

	psrad     MM4,14      ; divide by 2**14 after adjust
        add       esi,8       ; esi counts from 0 to 32

	psrad     MM5,14      ; divide by 2**14 after adjust
	cmp       esi,32

        packssdw  MM4,MM5
        pxor      MM5,MM5     ; clean registers for next sum.

        movq      MMWORD PTR [edi+esi*2-16],MM4 ;store 16 bit samples in output
	psrad     MM7,14      ; divide by 2**14 after adjust

	psrad     MM6,14      ; divide by 2**14 after adjust
        pxor      MM4,MM4     ; clean registers for next sum.

        packssdw  MM6,MM7    ; convert to 16 bit
        pxor      MM7,MM7    ; clean registers for next sum.

        movq      MMWORD PTR [edi+esi*2-8],MM6 ;store 16 bit samples in output
        pxor      MM6,MM6    ; clean registers for next sum.

		pxor	  MM2,MM2    ; disable first paddd MM7,MM2 in loop1
        jne       loop0
;-------------------------- end of _sbs() ------------------------------------------------------


        pop       esi
        pop       edi
        
        pop       ebx
        pop       ebp

		xor       eax,eax										; Return OK
		emms
        ret                                                     ; 590
_SubBandSynthesis_a ENDP

; -- End _SubBandSynthesis_a

;---------------------------------------------------------------
;		   multiplication of 8x8 matrix by vector
;---------------------------------------------------------------

_8x8MxV_mmx	PROC NEAR
; on input next registers should be loaded:
; eax,ecx,mm0,mm1,mm2

;   	mov       eax, DWORD PTR _data64
;   	mov       ecx, DWORD PTR _output8
;	movq	mm0,MMWORD PTR 0[eax] ; mm0: 0 1 2 3 : first 4 vector element
;	movq    mm2,MMWORD PTR 8[eax] ; mm2: 4 5 6 7 : last 4 vector element
;	movq	mm1,mm0


;   calculate 2 lines
;
;   results are scaled by 2^-14 and packed into 16 bit.
;

;--first iteration, and preparing mm0-mm3

	movq	mm4,MMWORD PTR 0[eax]	; from first iteration
	punpckldq mm0,mm0	; mm0: 0 1 0 1

	pmaddwd mm4,mm0			; from first iteration
	movq	mm3,mm2

	movq	mm5,MMWORD PTR 8[eax]	; from first iteration
	punpckhdq mm1,mm1 ; mm1: 2 3 2 3 elements

	movq	mm6,MMWORD PTR 16[eax]	; from first iteration
	pmaddwd mm5,mm1			; from first iteration

	movq	mm7,MMWORD PTR 24[eax]	; from first iteration
	punpckldq mm2,mm2   ; mm3 4 5 4 5

	pmaddwd mm6,mm2
	punpckhdq mm3,mm3   ; mm4 5 7 6 7 

	pmaddwd mm7,mm3
	paddd   mm5,mm4

;-- start second iteration and finish first

	movq	mm4,MMWORD PTR 32[eax]	; from SECOND iteration

	pmaddwd mm4,mm0			; from SECOND iteration
	paddd	mm6,mm5

	movq	mm5,MMWORD PTR 40[eax]	; from SECOND iteration
	paddd   mm7,mm6
	
	movq	mm6,MMWORD PTR 48[eax]	; from SECOND iteration
	pmaddwd mm5,mm1			; from SECOND iteration

	psrad	mm7,14
	pmaddwd mm6,mm2			; from SECOND iteration

;(EMPTY CYCLE)

;-- SECOND iteration

	movq	MMWORD PTR 0[ecx],mm7	; from first iteration
	movq	mm7,mm3

	pmaddwd mm7,MMWORD PTR 56[eax]
	paddd   mm5,mm4

	movq	mm4,MMWORD PTR 64[eax]  ; from third iteration
	paddd	mm6,mm5

	movq	mm5,MMWORD PTR 72[eax]	; from third iteration
	pmaddwd mm4,mm0			; from third iteration

	paddd   mm7,mm6
	pmaddwd mm5,mm1			; from third iteration

	movq	mm6,MMWORD PTR 80[eax]	; from third iteration
	psrad	mm7,14

	packssdw mm7,0[ecx]		; pack result of iteration 1 & 2
	pmaddwd mm6,mm2

	pmaddwd mm0,MMWORD PTR 96[eax]	; from FOURTH iteration
;(empty slot)

	movq	MMWORD PTR 0[ecx],mm7	; result of iteration 1 and 2
;(empty slot)

	pmaddwd mm1,MMWORD PTR 104[eax]	; from FOURTH iteration
	movq	mm7,mm3			; from third iteration
	
;- third iteration

	pmaddwd mm2,MMWORD PTR 112[eax]	; from FOURTH iteration
	paddd   mm5,mm4

	pmaddwd mm7,MMWORD PTR 88[eax]
	paddd	mm6,mm5

;- fourth iteration

	pmaddwd mm3,MMWORD PTR 120[eax]
	paddd   mm1,mm0

;To save TWO MORE CYCLES, put next 4 instructions after call, and they will take 2 cycles instead of 3.
;	paddd	mm2,mm1
;	
;	paddd	mm6,mm7
;
;	paddd   mm3,mm2
;	psrad	mm6,14

;let's do these instructions after call instruction to save cycle per instruction
;	psrad	mm3,14	
;	packssdw mm3,mm6		; pack result of iteration 3 & 4 
;	movq	MMWORD PTR 8[ecx],mm3	; store result of iteration 3 & 4

	ret
_8x8MxV_mmx ENDP

_TEXT ENDS

_data SEGMENT PARA PUBLIC USE32  'DATA'

align 4
bufOffset		DD 64							; make this local for each MPEG stream
shift			DD -64,0

align 8
oooozzzz		dq 0ffffffff00000000h
zzzzoooo		dq 000000000ffffffffh
zzzzoozz		dq 000000000ffff0000h

;-------------------- NEGATIVE MATRIXES ------------------------
; order ow rows is changed (to make packsdw easier)
even_even8x8:	
	SWORD -15136,  -6269, -13622,   3196,   6269,  15136,  16069,   9102
	SWORD  15136,   6269,  -9102, -16069,  -6269, -15136,  -3196,  13622
 	SWORD -16384, -16384, -16069, -13622, -16384, -16384,  -9102,  -3196
	SWORD -16384, -16384,   3196,   9102, -16384, -16384,  13622,  16069
 	SWORD  -6269,  15136,  -3196,   9102, -15136,   6269, -13622,  16069
	SWORD   6269, -15136, -16069,  13622,  15136,  -6269,  -9102,   3196
 	SWORD -11585,  11585,  -9102,  16069,  11585, -11585,  -3196, -13622
	SWORD -11585,  11585,  13622,   3196,  11585, -11585, -16069,   9102

even_odd8x8:	
	SWORD -14449,  -1605, -12665,   7723,  12665,  15678,  15678,  -1605
	SWORD   4756, -10393, -16305,  -4756, -16305,  -7723,  14449,  10393
	SWORD -16305, -15678, -15678, -10393, -14449, -12665,  -1605,   7723
	SWORD -10393,  -7723,  14449,  16305,  -4756,  -1605,  12665,   4756
	SWORD  -4756,  12665,  -1605,   4756, -16305,  14449,  -7723,  10393
	SWORD  -7723,  -1605, -12665,  14449,  10393, -15678, -15678,  16305
	SWORD -10393,  14449,  -7723,  16305,   4756, -16305, -10393,  -4756
	SWORD   1605,  15678,  15678, -12665,  -7723, -12665,  -1605,  14449


odd16x16:
	SWORD  16364,  16206,  15892,  15426,  16206,  14810,  12139,   8423,  15892,  12139,   5519,  -2404,  15426,   8423,  -2404, -12139
	SWORD  14810,  14053,  13159,  12139,   3980,   -803,  -5519,  -9759,  -9759, -14810, -16364, -14053, -16364, -13159,  -3980,   7005
	SWORD  -7005,  -8423,  -9759, -11002,  15892,  16364,  15426,  13159, -13159,  -7005,    803,   8423,    803,  -9759, -15892, -14810
	SWORD   -803,  -2404,  -3980,  -5519,   2404,   7005,  11002,  14053,  -3980, -11002, -15426, -16206,   5519,  14053,  16206,  11002
	SWORD  14810,   3980,  -9759, -16364,  14053,   -803, -14810, -13159,  13159,  -5519, -16364,  -3980,  12139,  -9759, -14053,   7005
	SWORD -11002,   2404,  14053,  15426,   2404,  15426,  12139,  -3980,  14053,  12139,  -7005, -16206,  15426,  -3980, -16206,    803
	SWORD  12139,  16206,   8423,  -5519, -16206,  -5519,  11002,  15892,   8423, -11002, -14810,   2404,   5519,  15892,  -2404, -16364
	SWORD  -7005, -15892, -13159,   -803,   8423,  16364,   7005,  -9759,  -9759, -15426,    803,  15892,  11002,  13159,  -8423, -14810
	SWORD  11002, -13159,  -8423,  14810,   9759, -15426,   -803,  15892,   8423, -16364,   7005,   9759,   7005, -15892,  13159,   -803
	SWORD   5519, -15892,  -2404,  16364,  -8423, -11002,  14810,   2404, -16206,   5519,  11002, -15892, -12139,  16206,  -8423,  -5519
	SWORD -15426,  -3980,  16206,    803,  14053, -12139,  -7005,  16206,  -2404,  15426, -12139,  -3980, -11002,  -2404,  14053, -15426
	SWORD -12139,  -9759,  14053,   7005,  13159,   5519, -16364,   3980, -14053,   -803,  14810, -13159,  14810,  -3980,  -9759,  16364
	SWORD   5519, -14053,  16206, -11002,   3980, -11002,  15426, -16206,   2404,  -7005,  11002, -14053,    803,  -2404,   3980,  -5519
	SWORD    803,   9759, -15892,  14810,  13159,  -7005,   -803,   8423,  15892, -16364,  15426, -13159,   7005,  -8423,   9759, -11002
	SWORD  16364, -13159,   3980,   7005,  -9759,  14810, -16364,  14053,  -3980,   -803,   5519,  -9759,  14810, -14053,  13159, -12139
	SWORD -15426,   8423,   2404, -12139,  15892, -12139,   5519,   2404, -16206,  14810, -12139,   8423,  16364, -16206,  15892, -15426
; window: -
; Table 3-B.3. Coefficients of Di of the Synthesis window
; from Page 229 in the ISO CD 11172 STANDARD converted to fix point 
; numbers. Scale factor is 16384 (2**14)

window:
	SWORD  0 ,-7 ; /* D[0] D[32] */
	SWORD  0 ,-8 ; /* D[1] D[33] */
	SWORD  0 ,-9 ; /* D[2] D[34] */
	SWORD  0 ,-10 ; /* D[3] D[35] */
	SWORD  0 ,-10 ; /* D[4] D[36] */
	SWORD  0 ,-11 ; /* D[5] D[37] */
	SWORD  0 ,-12 ; /* D[6] D[38] */
	SWORD  -1 ,-13 ; /* D[7] D[39] */
	SWORD  -1 ,-15 ; /* D[8] D[40] */
	SWORD  -1 ,-16 ; /* D[9] D[41] */
	SWORD  -1 ,-17 ; /* D[10] D[42] */
	SWORD  -1 ,-18 ; /* D[11] D[43] */
	SWORD  -1 ,-20 ; /* D[12] D[44] */
	SWORD  -1 ,-21 ; /* D[13] D[45] */
	SWORD  -1 ,-23 ; /* D[14] D[46] */
	SWORD  -1 ,-24 ; /* D[15] D[47] */
	SWORD  -1 ,-26 ; /* D[16] D[48] */
	SWORD  -2 ,-28 ; /* D[17] D[49] */
	SWORD  -2 ,-29 ; /* D[18] D[50] */
	SWORD  -2 ,-31 ; /* D[19] D[51] */
	SWORD  -2 ,-33 ; /* D[20] D[52] */
	SWORD  -2 ,-35 ; /* D[21] D[53] */
	SWORD  -3 ,-37 ; /* D[22] D[54] */
	SWORD  -3 ,-39 ; /* D[23] D[55] */
	SWORD  -3 ,-40 ; /* D[24] D[56] */
	SWORD  -3 ,-42 ; /* D[25] D[57] */
	SWORD  -4 ,-44 ; /* D[26] D[58] */
	SWORD  -4 ,-46 ; /* D[27] D[59] */
	SWORD  -5 ,-48 ; /* D[28] D[60] */
	SWORD  -5 ,-49 ; /* D[29] D[61] */
	SWORD  -6 ,-50 ; /* D[30] D[62] */
	SWORD  -7 ,-52 ; /* D[31] D[63] */
	SWORD  53 ,-115 ; /* D[64] D[96] */
	SWORD  55 ,-130 ; /* D[65] D[97] */
	SWORD  55 ,-145 ; /* D[66] D[98] */
	SWORD  56 ,-161 ; /* D[67] D[99] */
	SWORD  57 ,-178 ; /* D[68] D[100] */
	SWORD  57 ,-195 ; /* D[69] D[101] */
	SWORD  57 ,-212 ; /* D[70] D[102] */
	SWORD  57 ,-230 ; /* D[71] D[103] */
	SWORD  56 ,-248 ; /* D[72] D[104] */
	SWORD  55 ,-266 ; /* D[73] D[105] */
	SWORD  54 ,-284 ; /* D[74] D[106] */
	SWORD  52 ,-303 ; /* D[75] D[107] */
	SWORD  50 ,-321 ; /* D[76] D[108] */
	SWORD  47 ,-339 ; /* D[77] D[109] */
	SWORD  44 ,-357 ; /* D[78] D[110] */
	SWORD  41 ,-375 ; /* D[79] D[111] */
	SWORD  36 ,-392 ; /* D[80] D[112] */
	SWORD  32 ,-409 ; /* D[81] D[113] */
	SWORD  27 ,-425 ; /* D[82] D[114] */
	SWORD  21 ,-440 ; /* D[83] D[115] */
	SWORD  14 ,-454 ; /* D[84] D[116] */
	SWORD  7 ,-468 ; /* D[85] D[117] */
	SWORD  -1 ,-480 ; /* D[86] D[118] */
	SWORD  -9 ,-491 ; /* D[87] D[119] */
	SWORD  -18 ,-500 ; /* D[88] D[120] */
	SWORD  -28 ,-508 ; /* D[89] D[121] */
	SWORD  -38 ,-514 ; /* D[90] D[122] */
	SWORD  -49 ,-519 ; /* D[91] D[123] */
	SWORD  -61 ,-521 ; /* D[92] D[124] */
	SWORD  -74 ,-522 ; /* D[93] D[125] */
	SWORD  -87 ,-520 ; /* D[94] D[126] */
	SWORD  -100 ,-516 ; /* D[95] D[127] */
	SWORD  509 ,-1288 ; /* D[128] D[160] */
	SWORD  500 ,-1379 ; /* D[129] D[161] */
	SWORD  488 ,-1470 ; /* D[130] D[162] */
	SWORD  473 ,-1559 ; /* D[131] D[163] */
	SWORD  456 ,-1647 ; /* D[132] D[164] */
	SWORD  435 ,-1734 ; /* D[133] D[165] */
	SWORD  411 ,-1818 ; /* D[134] D[166] */
	SWORD  384 ,-1899 ; /* D[135] D[167] */
	SWORD  354 ,-1978 ; /* D[136] D[168] */
	SWORD  320 ,-2052 ; /* D[137] D[169] */
	SWORD  283 ,-2123 ; /* D[138] D[170] */
	SWORD  243 ,-2189 ; /* D[139] D[171] */
	SWORD  199 ,-2250 ; /* D[140] D[172] */
	SWORD  151 ,-2305 ; /* D[141] D[173] */
	SWORD  101 ,-2354 ; /* D[142] D[174] */
	SWORD  46 ,-2396 ; /* D[143] D[175] */
	SWORD  -11 ,-2432 ; /* D[144] D[176] */
	SWORD  -72 ,-2460 ; /* D[145] D[177] */
	SWORD  -136 ,-2479 ; /* D[146] D[178] */
	SWORD  -204 ,-2490 ; /* D[147] D[179] */
	SWORD  -274 ,-2492 ; /* D[148] D[180] */
	SWORD  -347 ,-2484 ; /* D[149] D[181] */
	SWORD  -423 ,-2466 ; /* D[150] D[182] */
	SWORD  -502 ,-2438 ; /* D[151] D[183] */
	SWORD  -583 ,-2398 ; /* D[152] D[184] */
	SWORD  -666 ,-2347 ; /* D[153] D[185] */
	SWORD  -751 ,-2285 ; /* D[154] D[186] */
	SWORD  -838 ,-2210 ; /* D[155] D[187] */
	SWORD  -926 ,-2123 ; /* D[156] D[188] */
	SWORD  -1016 ,-2023 ; /* D[157] D[189] */
	SWORD  -1106 ,-1910 ; /* D[158] D[190] */
	SWORD  -1197 ,-1784 ; /* D[159] D[191] */
	SWORD  1644 ,-9372 ; /* D[192] D[224] */
	SWORD  1490 ,-9834 ; /* D[193] D[225] */
	SWORD  1322 ,-10294 ; /* D[194] D[226] */
	SWORD  1140 ,-10752 ; /* D[195] D[227] */
	SWORD  944 ,-11205 ; /* D[196] D[228] */
	SWORD  734 ,-11654 ; /* D[197] D[229] */
	SWORD  509 ,-12098 ; /* D[198] D[230] */
	SWORD  271 ,-12534 ; /* D[199] D[231] */
	SWORD  17 ,-12963 ; /* D[200] D[232] */
	SWORD  -249 ,-13384 ; /* D[201] D[233] */
	SWORD  -531 ,-13795 ; /* D[202] D[234] */
	SWORD  -825 ,-14195 ; /* D[203] D[235] */
	SWORD  -1133 ,-14583 ; /* D[204] D[236] */
	SWORD  -1455 ,-14960 ; /* D[205] D[237] */
	SWORD  -1789 ,-15322 ; /* D[206] D[238] */
	SWORD  -2135 ,-15671 ; /* D[207] D[239] */
	SWORD  -2494 ,-16005 ; /* D[208] D[240] */
	SWORD  -2864 ,-16323 ; /* D[209] D[241] */
	SWORD  -3245 ,-16624 ; /* D[210] D[242] */
	SWORD  -3637 ,-16907 ; /* D[211] D[243] */
	SWORD  -4039 ,-17173 ; /* D[212] D[244] */
	SWORD  -4450 ,-17420 ; /* D[213] D[245] */
	SWORD  -4870 ,-17648 ; /* D[214] D[246] */
	SWORD  -5297 ,-17855 ; /* D[215] D[247] */
	SWORD  -5732 ,-18042 ; /* D[216] D[248] */
	SWORD  -6174 ,-18209 ; /* D[217] D[249] */
	SWORD  -6621 ,-18354 ; /* D[218] D[250] */
	SWORD  -7072 ,-18477 ; /* D[219] D[251] */
	SWORD  -7528 ,-18578 ; /* D[220] D[252] */
	SWORD  -7987 ,-18658 ; /* D[221] D[253] */
	SWORD  -8448 ,-18714 ; /* D[222] D[254] */
	SWORD  -8910 ,-18748 ; /* D[223] D[255] */
	SWORD  18760 ,9372 ; /* D[256] D[288] */
	SWORD  18748 ,8910 ; /* D[257] D[289] */
	SWORD  18714 ,8448 ; /* D[258] D[290] */
	SWORD  18658 ,7987 ; /* D[259] D[291] */
	SWORD  18578 ,7528 ; /* D[260] D[292] */
	SWORD  18477 ,7072 ; /* D[261] D[293] */
	SWORD  18354 ,6621 ; /* D[262] D[294] */
	SWORD  18209 ,6174 ; /* D[263] D[295] */
	SWORD  18042 ,5732 ; /* D[264] D[296] */
	SWORD  17855 ,5297 ; /* D[265] D[297] */
	SWORD  17648 ,4870 ; /* D[266] D[298] */
	SWORD  17420 ,4450 ; /* D[267] D[299] */
	SWORD  17173 ,4039 ; /* D[268] D[300] */
	SWORD  16907 ,3637 ; /* D[269] D[301] */
	SWORD  16624 ,3245 ; /* D[270] D[302] */
	SWORD  16323 ,2864 ; /* D[271] D[303] */
	SWORD  16005 ,2494 ; /* D[272] D[304] */
	SWORD  15671 ,2135 ; /* D[273] D[305] */
	SWORD  15322 ,1789 ; /* D[274] D[306] */
	SWORD  14960 ,1455 ; /* D[275] D[307] */
	SWORD  14583 ,1133 ; /* D[276] D[308] */
	SWORD  14195 ,825 ; /* D[277] D[309] */
	SWORD  13795 ,531 ; /* D[278] D[310] */
	SWORD  13384 ,249 ; /* D[279] D[311] */
	SWORD  12963 ,-17 ; /* D[280] D[312] */
	SWORD  12534 ,-271 ; /* D[281] D[313] */
	SWORD  12098 ,-509 ; /* D[282] D[314] */
	SWORD  11654 ,-734 ; /* D[283] D[315] */
	SWORD  11205 ,-944 ; /* D[284] D[316] */
	SWORD  10752 ,-1140 ; /* D[285] D[317] */
	SWORD  10294 ,-1322 ; /* D[286] D[318] */
	SWORD  9834 ,-1490 ; /* D[287] D[319] */
	SWORD  1644 ,1288 ; /* D[320] D[352] */
	SWORD  1784 ,1197 ; /* D[321] D[353] */
	SWORD  1910 ,1106 ; /* D[322] D[354] */
	SWORD  2023 ,1016 ; /* D[323] D[355] */
	SWORD  2123 ,926 ; /* D[324] D[356] */
	SWORD  2210 ,838 ; /* D[325] D[357] */
	SWORD  2285 ,751 ; /* D[326] D[358] */
	SWORD  2347 ,666 ; /* D[327] D[359] */
	SWORD  2398 ,583 ; /* D[328] D[360] */
	SWORD  2438 ,502 ; /* D[329] D[361] */
	SWORD  2466 ,423 ; /* D[330] D[362] */
	SWORD  2484 ,347 ; /* D[331] D[363] */
	SWORD  2492 ,274 ; /* D[332] D[364] */
	SWORD  2490 ,204 ; /* D[333] D[365] */
	SWORD  2479 ,136 ; /* D[334] D[366] */
	SWORD  2460 ,72 ; /* D[335] D[367] */
	SWORD  2432 ,11 ; /* D[336] D[368] */
	SWORD  2396 ,-46 ; /* D[337] D[369] */
	SWORD  2354 ,-101 ; /* D[338] D[370] */
	SWORD  2305 ,-151 ; /* D[339] D[371] */
	SWORD  2250 ,-199 ; /* D[340] D[372] */
	SWORD  2189 ,-243 ; /* D[341] D[373] */
	SWORD  2123 ,-283 ; /* D[342] D[374] */
	SWORD  2052 ,-320 ; /* D[343] D[375] */
	SWORD  1978 ,-354 ; /* D[344] D[376] */
	SWORD  1899 ,-384 ; /* D[345] D[377] */
	SWORD  1818 ,-411 ; /* D[346] D[378] */
	SWORD  1734 ,-435 ; /* D[347] D[379] */
	SWORD  1647 ,-456 ; /* D[348] D[380] */
	SWORD  1559 ,-473 ; /* D[349] D[381] */
	SWORD  1470 ,-488 ; /* D[350] D[382] */
	SWORD  1379 ,-500 ; /* D[351] D[383] */
	SWORD  509 ,115 ; /* D[384] D[416] */
	SWORD  516 ,100 ; /* D[385] D[417] */
	SWORD  520 ,87 ; /* D[386] D[418] */
	SWORD  522 ,74 ; /* D[387] D[419] */
	SWORD  521 ,61 ; /* D[388] D[420] */
	SWORD  519 ,49 ; /* D[389] D[421] */
	SWORD  514 ,38 ; /* D[390] D[422] */
	SWORD  508 ,28 ; /* D[391] D[423] */
	SWORD  500 ,18 ; /* D[392] D[424] */
	SWORD  491 ,9 ; /* D[393] D[425] */
	SWORD  480 ,1 ; /* D[394] D[426] */
	SWORD  468 ,-7 ; /* D[395] D[427] */
	SWORD  454 ,-14 ; /* D[396] D[428] */
	SWORD  440 ,-21 ; /* D[397] D[429] */
	SWORD  425 ,-27 ; /* D[398] D[430] */
	SWORD  409 ,-32 ; /* D[399] D[431] */
	SWORD  392 ,-36 ; /* D[400] D[432] */
	SWORD  375 ,-41 ; /* D[401] D[433] */
	SWORD  357 ,-44 ; /* D[402] D[434] */
	SWORD  339 ,-47 ; /* D[403] D[435] */
	SWORD  321 ,-50 ; /* D[404] D[436] */
	SWORD  303 ,-52 ; /* D[405] D[437] */
	SWORD  284 ,-54 ; /* D[406] D[438] */
	SWORD  266 ,-55 ; /* D[407] D[439] */
	SWORD  248 ,-56 ; /* D[408] D[440] */
	SWORD  230 ,-57 ; /* D[409] D[441] */
	SWORD  212 ,-57 ; /* D[410] D[442] */
	SWORD  195 ,-57 ; /* D[411] D[443] */
	SWORD  178 ,-57 ; /* D[412] D[444] */
	SWORD  161 ,-56 ; /* D[413] D[445] */
	SWORD  145 ,-55 ; /* D[414] D[446] */
	SWORD  130 ,-55 ; /* D[415] D[447] */
	SWORD  53 ,7 ; /* D[448] D[480] */
	SWORD  52 ,7 ; /* D[449] D[481] */
	SWORD  50 ,6 ; /* D[450] D[482] */
	SWORD  49 ,5 ; /* D[451] D[483] */
	SWORD  48 ,5 ; /* D[452] D[484] */
	SWORD  46 ,4 ; /* D[453] D[485] */
	SWORD  44 ,4 ; /* D[454] D[486] */
	SWORD  42 ,3 ; /* D[455] D[487] */
	SWORD  40 ,3 ; /* D[456] D[488] */
	SWORD  39 ,3 ; /* D[457] D[489] */
	SWORD  37 ,3 ; /* D[458] D[490] */
	SWORD  35 ,2 ; /* D[459] D[491] */
	SWORD  33 ,2 ; /* D[460] D[492] */
	SWORD  31 ,2 ; /* D[461] D[493] */
	SWORD  29 ,2 ; /* D[462] D[494] */
	SWORD  28 ,2 ; /* D[463] D[495] */
	SWORD  26 ,1 ; /* D[464] D[496] */
	SWORD  24 ,1 ; /* D[465] D[497] */
	SWORD  23 ,1 ; /* D[466] D[498] */
	SWORD  21 ,1 ; /* D[467] D[499] */
	SWORD  20 ,1 ; /* D[468] D[500] */
	SWORD  18 ,1 ; /* D[469] D[501] */
	SWORD  17 ,1 ; /* D[470] D[502] */
	SWORD  16 ,1 ; /* D[471] D[503] */
	SWORD  15 ,1 ; /* D[472] D[504] */
	SWORD  13 ,1 ; /* D[473] D[505] */
	SWORD  12 ,0 ; /* D[474] D[506] */
	SWORD  11 ,0 ; /* D[475] D[507] */
	SWORD  10 ,0 ; /* D[476] D[508] */
	SWORD  10 ,0 ; /* D[477] D[509] */
	SWORD  9 ,0 ; /* D[478] D[510] */
	SWORD  8 ,0 ; /* D[479] D[511] */

_DATA ENDS

	END
