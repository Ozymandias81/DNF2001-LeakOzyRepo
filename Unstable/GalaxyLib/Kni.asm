; ƒ- Internal revision no. 5.00b -ƒƒƒƒ Last revision at 14:01 on 06-04-1999 -ƒƒ
;
;                      The 32 bit x86-KNI Assembly source
;
;               €€€ﬂﬂ€€€ €€€ﬂ€€€ €€€    €€€ﬂ€€€ €€€  €€€ €€€ €€€
;               €€€  ﬂﬂﬂ €€€ €€€ €€€    €€€ €€€  ﬂ€€€€ﬂ  €€€ €€€
;               €€€ ‹‹‹‹ €€€‹€€€ €€€    €€€‹€€€    €€     ﬂ€€€ﬂ
;               €€€  €€€ €€€ €€€ €€€    €€€ €€€  ‹€€€€‹    €€€
;               €€€‹‹€€€ €€€ €€€ €€€‹‹‹ €€€ €€€ €€€  €€€   €€€
;
;                               MUSIC SYSTEM 
;               This document contains confidential information
;                    Copyright (c) 1993-97 Carlo Vogelsang
;
; ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
; ≥€≤± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±≤€≥
; √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
; ≥ This source file, KNI.ASM    is Copyright (c) 1993-99 by Carlo Vogelsang. ≥
; ≥ You may not copy, distribute,  duplicate or clone this file  in any form, ≥
; ≥ modified or non-modified. It belongs to the author.  By copying this file ≥
; ≥ you are violating laws and will be punished. I will knock your brains in  ≥
; ≥ myself or you will be sued to death..                                     ≥
; ≥                                                                     Carlo ≥
; ¿ƒ( How the fuck did you get this file anyway? )ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
;
.586
.MMX
.K3D
.MODEL          FLAT

.CODE

include			hdr\kni.inc
include			hdr\galaxy.ah

;***************************************************************************************
;Lightspeed ]I[ mixing routines, KNI optimized, 32 bit stereo, interpolated, dual efx
;***************************************************************************************

kniMixerStereo  PROC      NEAR C Dry: DWord, EffectA: DWord, EffectB: DWord, Count: DWord, SampleInt: DWord, SampleFrac: Word, PitchShift: DWord, LeftVolume: Word, RightVolume: Word, LeftEffectA: Word, RightEffectA: Word, LeftEffectB: Word, RightEffectB: Word, Mode: Byte
                pushad

                test      Mode,4                        ; Need surround ?
                jz        @@kniNormal                   ; Nope ? Go on..

                neg       RightVolume                   ; 180 deg phase-shift
				neg	      RightEffectA					; 180 deg phase-shift

				neg		  RightEffectB					; 180 deg phase-shift
				;
@@kniNormal:
				and		  SampleFrac,not 1				; Adjust for limited				
				and		  PitchShift,not 1				; fractional resolution

                ;Setup volumes in "volumes" (Right/Left/Right/Left)
                movsx     eax,LeftVolume				; Get 15 bit L/R Vols
				cvtsi2ss  xmm0,eax						; Convert to float
				movsx     eax,RightVolume				; ...
				cvtsi2ss  xmm1,eax						; Convert to float
				unpcklps  xmm0,xmm1						; XMM0 = RightVol LeftVol
				mulps     xmm0,SendScale 				; Multiply by 1/32768*1/32768
				movlps	  DrySend,xmm0					; Store DrySend level
				movlps	  DrySend+8,xmm0				; Store DrySend level
			
                movsx     eax,LeftEffectA				; Get 15 bit L/R Vols
				cvtsi2ss  xmm0,eax						; Convert to float
				movsx     eax,RightEffectA				; ...
				cvtsi2ss  xmm1,eax						; Convert to float
				unpcklps  xmm0,xmm1						; XMM0 = RightVol LeftVol
				mulps     xmm0,SendScale 				; Multiply by 1/32768*1/32768
				movlps	  EffectASend,xmm0				; Store EffectASend level
				movlps	  EffectASend+8,xmm0			; Store EffectASend level

                movsx     eax,LeftEffectB				; Get 15 bit L/R Vols
				cvtsi2ss  xmm0,eax						; Convert to float
				movsx     eax,RightEffectB				; ...
				cvtsi2ss  xmm1,eax						; Convert to float
				unpcklps  xmm0,xmm1						; XMM0 = RightVol LeftVol
				mulps     xmm0,SendScale 				; Multiply by 1/32768*1/32768
				movlps	  EffectBSend,xmm0				; Store EffectBSend level
				movlps	  EffectBSend+8,xmm0			; Store EffectBSend level

                ;Setup fractional shit in MM3
                mov       ax,word ptr SampleFrac        ; Get fraction in AX
				;

				mov       bx,ax                         ; BX=Fraction
                not       bx                            ; BX=(1-Fraction)

				shl       ebx,16                        ; Copy to E(BX)..
				;

                mov       bx,ax                         ; BX=Fraction
				;

				movd      mm3,ebx                       ; 1-frac/frac
				;

                mov       bx,ax                         ; BX=Fraction
				;

                add       bx,word ptr PitchShift        ; BX=Frac+st
				;

                not       bx                            ; BX=1-Frac-st
				;

				shl       ebx,16                        ; Copy to E(BX)..
				;

                mov       bx,ax                         ; BX=Frac
				;

                add       bx,word ptr PitchShift        ; BX=Frac+st
				;

                movd      mm4,ebx                       ; 1-frac-st/frac+st
				;

                ;Setup -step/step in MM4
                mov       bx,word ptr PitchShift        ; BX=Step
				;
                
				neg       bx                            ; BX=-Step
				;
                
				shl       ebx,16						; Copy to E(BX)..
				;
                
				mov       bx,word ptr PitchShift        ; BX=Step
                punpckldq mm3,mm4

				movd      mm4,ebx                       ; Setup -step/step
                psrlw     mm3,1							; 15 bit fractions in MM3

			    mov		  TempESP,esp
                punpckldq mm4,mm4                       ; in MM4..

                movq      mm5,qword ptr FractionMask    ; Setup fraction mask
                psraw     mm4,1							; 15 bit steps in MM4

;               test      Mode,2                        ; Need filtering ?
;               jnz       @@kniFilter                   ; Yope ? Use it..

;               movq      mm3,qword ptr FractionHold    ; Setup fractions in MM3
;               pxor      mm4,mm4                       ; Clear MM4 (Steps)
@@kniFilter:    
				test      Mode,1                        ; Need 16 bit mixing ?
                jnz       @@Mix16                       ; Yope ? Do it..

;******************************************************************************
;Lightspeed ]I[ mixing routines, KNI optimized, 8 bit input samples.
;******************************************************************************

@@Mix8:	    
				mov       dx,word ptr SampleFrac
                mov       esi,SampleInt

                shl       edx,16
                mov       edi,Dry
               
				mov       dx,word ptr Count
				mov		  eax,EffectA
                
				mov       sp,word ptr PitchShift
				mov		  ebx,EffectB

                shl       esp,16
                mov       ebp,PitchShift

                sar       ebp,16
				xor		  ecx,ecx

                mov       ch,[esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				;

                adc       esi,ebp
				;

                movd      mm0,ecx
				;

                mov       ch,[esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				;

                movd      mm1,ecx
				;
			
                adc       esi,ebp
                punpckldq mm0,mm1

				pmaddwd	  mm0,mm3
				paddw	  mm3,mm4
				
				movq	  mm1,mm0
				punpckldq mm0,mm0

				punpckhdq mm1,mm1
				paddw     mm3,mm4

				cvtpi2ps  xmm0,_mm0
				pand	  mm3,mm5

				cvtpi2ps  xmm1,_mm1
                test      edi,15
				
				;
                jz        @@Mix8MainEnd

				movd      mm0,ecx
                mov       ch,[esi]

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				psubw	  mm3,mm4

                movd      mm1,ecx
				pand	  mm3,mm5
                
				adc       esi,ebp
				punpckldq mm0,mm1

				pmaddwd	  mm0,mm3
				movaps	  xmm1,xmm0

				mulps     xmm0,DrySend
				movaps	  xmm2,xmm1

				mulps     xmm1,EffectASend
				paddw	  mm3,mm4
				
				mulps     xmm2,EffectBSend
				paddw	  mm3,mm4

				movlps	  xmm3,[edi]
				pand      mm3,mm5

				movlps	  xmm4,[eax]
				addps     xmm0,xmm3 

				movlps	  xmm5,[ebx]
				addps     xmm1,xmm4 
				
				movq	  mm1,mm0
				addps     xmm2,xmm5 

				movlps	  [edi],xmm0
				punpckldq mm0,mm0

				movlps	  [eax],xmm1
				punpckhdq mm1,mm1

				movlps	  [ebx],xmm2
				cvtpi2ps  xmm0,_mm0

				cvtpi2ps  xmm1,_mm1
				add		  eax,8

				add		  ebx,8
				;
				
				sub		  dx,1h
				add       edi,8

                sub       dx,4h
                js        @@Mix8End
@@Mix8MainLoop:
				mov       ch,[esi]
				shufps    xmm0,xmm1,01000100b

                shl       ecx,16
				movaps	  xmm1,xmm0

                add       edx,esp
				movaps	  xmm2,xmm1

                mov       ch,[esi+1]
				mulps     xmm0,DrySend

                adc       esi,ebp
				mulps     xmm1,EffectASend

                movd      mm0,ecx
				mulps     xmm2,EffectBSend

                mov       ch,[esi]
				addps     xmm0,[edi]
				
                shl       ecx,16
				addps     xmm1,[eax]
				
                add       edx,esp
				addps     xmm2,[ebx]

                mov       ch,[esi+1]
				movaps	  [edi],xmm0
			
				movd      mm1,ecx
				movaps	  [eax],xmm1

				punpckldq mm0,mm1
   				movaps	  [ebx],xmm2

				adc       esi,ebp
				pmaddwd	  mm0,mm3

				paddw	  mm3,mm4
				paddw	  mm3,mm4

				pand      mm3,mm5
				;

				movq	  mm1,mm0
				punpckldq mm0,mm0
				
				punpckhdq mm1,mm1
				cvtpi2ps  xmm0,_mm0

				cvtpi2ps  xmm1,_mm1
				;

				mov       ch,[esi]
				shufps    xmm0,xmm1,01000100b

                shl       ecx,16
				movaps	  xmm1,xmm0

                add       edx,esp
				movaps	  xmm2,xmm1

                mov       ch,[esi+1]
				mulps     xmm0,DrySend

                adc       esi,ebp
				mulps     xmm1,EffectASend

                movd      mm0,ecx
				mulps     xmm2,EffectBSend

                mov       ch,[esi]
				addps     xmm0,[edi+16]
				
                shl       ecx,16
				addps     xmm1,[eax+16]
				
                add       edx,esp
				addps     xmm2,[ebx+16]

                mov       ch,[esi+1]
				movaps	  [edi+16],xmm0
			
				movd      mm1,ecx
				movaps	  [eax+16],xmm1

				punpckldq mm0,mm1
   				movaps	  [ebx+16],xmm2

				adc       esi,ebp
				pmaddwd	  mm0,mm3

				paddw	  mm3,mm4
				paddw	  mm3,mm4

				pand      mm3,mm5
				;

				movq	  mm1,mm0
				punpckldq mm0,mm0
				
				punpckhdq mm1,mm1
				cvtpi2ps  xmm0,_mm0

				cvtpi2ps  xmm1,_mm1
				;

				add		  eax,32
				add		  ebx,32
				
				add       edi,32
				;
@@Mix8MainEnd:
                sub       dx,4h
                jns       @@Mix8MainLoop
@@Mix8End:
				add       dx,4h-1h
                js        @@MixDone
@@Mix8EndLoop:
				movd	  mm0,ecx
				;

                mov       ch,[esi]
				shufps    xmm0,xmm1,01000100b

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				psubw	  mm3,mm4

                movd      mm1,ecx
				pand	  mm3,mm5
				
				punpckldq mm0,mm1
				movaps	  xmm1,xmm0

                adc       esi,ebp
				pmaddwd	  mm0,mm3

				mulps     xmm0,DrySend
				movaps	  xmm2,xmm1

				mulps     xmm1,EffectASend
				paddw	  mm3,mm4
				
				mulps     xmm2,EffectBSend
				paddw	  mm3,mm4

				movlps	  xmm3,[edi]
				pand      mm3,mm5

				movlps	  xmm4,[eax]
				addps     xmm0,xmm3 

				movlps	  xmm5,[ebx]
				addps     xmm1,xmm4 
				
				movq	  mm1,mm0
				addps     xmm2,xmm5 

				movlps	  [edi],xmm0
				punpckldq mm0,mm0

				movlps	  [eax],xmm1
				punpckhdq mm1,mm1

				movlps	  [ebx],xmm2
				cvtpi2ps  xmm0,_mm0

				cvtpi2ps  xmm1,_mm1
				add		  eax,8

				add		  ebx,8
				add		  edi,8

                sub       dx,1h
                jns       @@Mix8EndLoop

				jmp		  @@MixDone

;******************************************************************************
;Lightspeed ]I[ mixing routines, KNI optimized, 16 bit input samples.
;******************************************************************************

@@Mix16:	    
				mov       dx,word ptr SampleFrac
                mov       esi,SampleInt

                shl       edx,16
                mov       edi,Dry
               
				mov       dx,word ptr Count
				mov		  eax,EffectA
                
				mov       sp,word ptr PitchShift
				mov		  ebx,EffectB

                shl       esp,16
                mov       ebp,PitchShift

                sar       ebp,16
                mov       cx,[esi+esi]

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				;

                adc       esi,ebp
				;

                movd      mm0,ecx
				;

                mov       cx,[esi+esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				;

                movd      mm1,ecx
				;
			
				adc       esi,ebp
                punpckldq mm0,mm1

				pmaddwd	  mm0,mm3
				paddw	  mm3,mm4
				
				movq	  mm1,mm0
				punpckldq mm0,mm0

				punpckhdq mm1,mm1
				paddw     mm3,mm4

				cvtpi2ps  xmm0,_mm0
				pand	  mm3,mm5

				cvtpi2ps  xmm1,_mm1
                test      edi,15
				
				;
                jz        @@Mix16MainEnd

				movd      mm0,ecx
                mov       cx,[esi+esi]

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				psubw	  mm3,mm4

                movd      mm1,ecx
				pand	  mm3,mm5
                
				adc       esi,ebp
				punpckldq mm0,mm1

				pmaddwd	  mm0,mm3
				movaps	  xmm1,xmm0

				mulps     xmm0,DrySend
				movaps	  xmm2,xmm1

				mulps     xmm1,EffectASend
				paddw	  mm3,mm4
				
				mulps     xmm2,EffectBSend
				paddw	  mm3,mm4

				movlps	  xmm3,[edi]
				pand      mm3,mm5

				movlps	  xmm4,[eax]
				addps     xmm0,xmm3 

				movlps	  xmm5,[ebx]
				addps     xmm1,xmm4 
				
				movq	  mm1,mm0
				addps     xmm2,xmm5 

				movlps	  [edi],xmm0
				punpckldq mm0,mm0

				movlps	  [eax],xmm1
				punpckhdq mm1,mm1

				movlps	  [ebx],xmm2
				cvtpi2ps  xmm0,_mm0

				cvtpi2ps  xmm1,_mm1
				add		  eax,8

				add		  ebx,8
				;
				
				sub		  dx,1h
				add       edi,8

                sub       dx,4h
                js        @@Mix16End
@@Mix16MainLoop:
				mov       cx,[esi+esi]
				shufps    xmm0,xmm1,01000100b

                shl       ecx,16
				movaps	  xmm1,xmm0

                add       edx,esp
				movaps	  xmm2,xmm1

                mov       cx,[esi+esi+2]
				mulps     xmm0,DrySend

                adc       esi,ebp
				mulps     xmm1,EffectASend

                movd      mm0,ecx
				mulps     xmm2,EffectBSend

                mov       cx,[esi+esi]
				addps     xmm0,[edi]
				
                shl       ecx,16
				addps     xmm1,[eax]
				
                add       edx,esp
				addps     xmm2,[ebx]

                mov       cx,[esi+esi+2]
				movaps	  [edi],xmm0
			
				movd      mm1,ecx
				movaps	  [eax],xmm1

				punpckldq mm0,mm1
   				movaps	  [ebx],xmm2

				adc       esi,ebp
				pmaddwd	  mm0,mm3

				paddw	  mm3,mm4
				paddw	  mm3,mm4

				pand      mm3,mm5
				;

				movq	  mm1,mm0
				punpckldq mm0,mm0
				
				punpckhdq mm1,mm1
				cvtpi2ps  xmm0,_mm0

				cvtpi2ps  xmm1,_mm1
				;

				mov       cx,[esi+esi]
				shufps    xmm0,xmm1,01000100b

                shl       ecx,16
				movaps	  xmm1,xmm0

                add       edx,esp
				movaps	  xmm2,xmm1

                mov       cx,[esi+esi+2]
				mulps     xmm0,DrySend

                adc       esi,ebp
				mulps     xmm1,EffectASend

                movd      mm0,ecx
				mulps     xmm2,EffectBSend

                mov       cx,[esi+esi]
				addps     xmm0,[edi+16]
				
                shl       ecx,16
				addps     xmm1,[eax+16]
				
                add       edx,esp
				addps     xmm2,[ebx+16]

                mov       cx,[esi+esi+2]
				movaps	  [edi+16],xmm0
			
				movd      mm1,ecx
				movaps	  [eax+16],xmm1

				punpckldq mm0,mm1
   				movaps	  [ebx+16],xmm2

				adc       esi,ebp
				pmaddwd	  mm0,mm3

				paddw	  mm3,mm4
				paddw	  mm3,mm4

				pand      mm3,mm5
				;

				movq	  mm1,mm0
				punpckldq mm0,mm0
				
				punpckhdq mm1,mm1
				cvtpi2ps  xmm0,_mm0

				cvtpi2ps  xmm1,_mm1
				;

				add		  eax,32
				add		  ebx,32
				
				add       edi,32
				;
@@Mix16MainEnd:
                sub       dx,4h
                jns       @@Mix16MainLoop
@@Mix16End:
				add       dx,4h-1h
                js        @@MixDone
@@Mix16EndLoop:
				movd	  mm0,ecx
				;

                mov       cx,[esi+esi]
				shufps    xmm0,xmm1,01000100b

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				psubw	  mm3,mm4

                movd      mm1,ecx
				pand	  mm3,mm5
				
				punpckldq mm0,mm1
				movaps	  xmm1,xmm0

                adc       esi,ebp
				pmaddwd	  mm0,mm3

				mulps     xmm0,DrySend
				movaps	  xmm2,xmm1

				mulps     xmm1,EffectASend
				paddw	  mm3,mm4
				
				mulps     xmm2,EffectBSend
				paddw	  mm3,mm4

				movlps	  xmm3,[edi]
				pand      mm3,mm5

				movlps	  xmm4,[eax]
				addps     xmm0,xmm3 

				movlps	  xmm5,[ebx]
				addps     xmm1,xmm4 
				
				movq	  mm1,mm0
				addps     xmm2,xmm5 

				movlps	  [edi],xmm0
				punpckldq mm0,mm0

				movlps	  [eax],xmm1
				punpckhdq mm1,mm1

				movlps	  [ebx],xmm2
				cvtpi2ps  xmm0,_mm0

				cvtpi2ps  xmm1,_mm1
				add		  eax,8

				add		  ebx,8
				add		  edi,8

                sub       dx,1h
                jns       @@Mix16EndLoop

@@MixDone:      mov		  esp,TempESP

				emms
				
				popad

                ret
kniMixerStereo  ENDP

kniMixerStereoSize equ    $-kniMixerStereo

;*******************************************************************************
;Lightspeed ]I[ digital effects routine, KNI optimized, 32 bit input samples.
;*******************************************************************************

kniReverb		PROC	  NEAR C DSPReverb: DWord, DSPDestBuffer: DWord, DSPSourceBuffer, DSPBufferSize: DWord, Flags: DWord
				pushad

				mov		  eax,DSPBufferSize
				mov		  TempEBP,eax

				mov		  esi,DSPSourceBuffer
				mov		  edi,DSPDestBuffer

				mov		  edx,DSPReverb
				mov		  ecx,dword ptr [edx+glxKNIReverb.time]

				movlps	  xmm0,dword ptr [edx+glxKNIReverb.leftout]
				movlps	  xmm4,dword ptr [edx+glxKNIReverb.apf0lpfout]
				movlps	  xmm5,dword ptr [edx+glxKNIReverb.apf2lpfout]
				movlps	  xmm6,dword ptr [edx+glxKNIReverb.apf4lpfout]

@@ReverbMainLoop:				
				shufps	  xmm0,xmm0,00000001b								; do left/right crossing
				movlps	  xmm7,[esi]
				addps	  xmm0,xmm7
				movlps	  xmm7,revoutsend
				mulps	  xmm0,xmm7
				add		  esi,8

				;Update one allpass filter for left and right
				movaps	  xmm1,xmm0
				movlps	  xmm7,[edx+glxKNIReverb.apf0gain0]
				mulps     xmm0,xmm7											; -gain
				movlps	  xmm7,[edx+glxKNIReverb.apf0lpfb]				
				mov	      ebp,[edx+glxKNIReverb.td0]
				lea		  ebx,[ecx+ebp]
				mov	      ebp,[edx+glxKNIReverb.td1]
				and		  ebx,3fffh
				movss	  xmm2,dword ptr [edx+ebx*8+glxKNIReverb.buf01]
				lea		  ebx,[ecx+ebp]
				mulps	  xmm4,xmm7
				movlps	  xmm7,[edx+glxKNIReverb.apf0lpfa]
				and		  ebx,3fffh
				movss	  xmm3,dword ptr [edx+ebx*8+glxKNIReverb.buf01+4]
				unpcklps  xmm2,xmm3
				movaps    xmm3,xmm2
				mulps     xmm3,xmm7
				movlps	  xmm7,[edx+glxKNIReverb.apf0gain1]
				addps     xmm3,xmm4
				movaps	  xmm4,xmm3
				mulps     xmm3,xmm7											;  gain
				movlps	  xmm7,[edx+glxKNIReverb.apf0gain2]
				addps	  xmm1,xmm3
				movlps	  dword ptr [edx+ecx*8+glxKNIReverb.buf01],xmm1
				mulps	  xmm2,xmm7											;1-gain^2
				addps	  xmm0,xmm2

				;Update one allpass filter for left and right
				movaps	  xmm1,xmm0
				movlps	  xmm7,[edx+glxKNIReverb.apf2gain0]
				mulps     xmm0,xmm7											; -gain
				movlps	  xmm7,[edx+glxKNIReverb.apf2lpfb]
				mov	      ebp,[edx+glxKNIReverb.td2]
				lea		  ebx,[ecx+ebp]
				mov	      ebp,[edx+glxKNIReverb.td3]
				and		  ebx,3fffh
				movss	  xmm2,dword ptr [edx+ebx*8+glxKNIReverb.buf23]
				lea		  ebx,[ecx+ebp]
				mulps	  xmm5,xmm7
				movlps	  xmm7,[edx+glxKNIReverb.apf2lpfa]
				and		  ebx,3fffh
				movss	  xmm3,dword ptr [edx+ebx*8+glxKNIReverb.buf23+4]
				unpcklps  xmm2,xmm3
				movaps    xmm3,xmm2
				mulps     xmm3,xmm7
				movlps	  xmm7,[edx+glxKNIReverb.apf2gain1]
				addps     xmm3,xmm5
				movaps	  xmm5,xmm3
				mulps     xmm3,xmm7											;  gain
				movlps    xmm7,[edx+glxKNIReverb.apf2gain2]
				addps	  xmm1,xmm3
				movlps	  dword ptr [edx+ecx*8+glxKNIReverb.buf23],xmm1
				mulps	  xmm2,xmm7											;1-gain^2
				addps	  xmm0,xmm2

				;Update one allpass filter for left and right
				movaps	  xmm1,xmm0
				movlps	  xmm7,[edx+glxKNIReverb.apf4gain0]
				mulps     xmm0,xmm7 										; -gain
				movlps	  xmm7,[edx+glxKNIReverb.apf4lpfb]
				mov	      ebp,[edx+glxKNIReverb.td4]
				lea		  ebx,[ecx+ebp]
				mov	      ebp,[edx+glxKNIReverb.td5]
				and		  ebx,3fffh
				movss	  xmm2,dword ptr [edx+ebx*8+glxKNIReverb.buf45]
				lea		  ebx,[ecx+ebp]
				mulps	  xmm6,xmm7
				movlps	  xmm7,[edx+glxKNIReverb.apf4lpfa]
				and		  ebx,3fffh
				movss	  xmm3,dword ptr [edx+ebx*8+glxKNIReverb.buf45+4]
				unpcklps  xmm2,xmm3
				movaps    xmm3,xmm2
				mulps     xmm3,xmm7 
				movlps	  xmm7,[edx+glxKNIReverb.apf4gain1]
				addps     xmm3,xmm6
				movaps	  xmm6,xmm3
				mulps     xmm3,xmm7 										;  gain
				movlps	  xmm7,[edx+glxKNIReverb.apf4gain2]
				addps	  xmm1,xmm3
				movlps	  dword ptr [edx+ecx*8+glxKNIReverb.buf45],xmm1
				mulps	  xmm2,xmm7 										;1-gain^2
				addps	  xmm0,xmm2
				movlps	  xmm2,[edx+glxKNIReverb.wetleft]

				movaps	  xmm7,xmm0
				movlps	  xmm3,[edi]
				mulps     xmm7,xmm2
				addps     xmm7,xmm3
				inc		  ecx
				and		  ecx,3fffh
				movlps	  [edi],xmm7
				add		  edi,8

				dec		  TempEBP
				jnz		  @@ReverbMainLoop

				mov		  dword ptr [edx+glxKNIReverb.time],ecx
				movlps	  dword ptr [edx+glxKNIReverb.leftout],xmm0
				movlps	  dword ptr [edx+glxKNIReverb.apf0lpfout],xmm4
				movlps	  dword ptr [edx+glxKNIReverb.apf2lpfout],xmm5
				movlps	  dword ptr [edx+glxKNIReverb.apf4lpfout],xmm6
@@ReverbDone:   
				emms

                popad

                ret
kniReverb		ENDP

;*******************************************************************************
;Lightspeed ]I[ digital effects routine, KNI optimized, 32 bit input samples.
;*******************************************************************************

kniChorus		PROC	  NEAR C DSPChorus: DWord, DSPDestBuffer: DWord, DSPSourceBuffer, DSPBufferSize: DWord, Flags: DWord
				pushad

				mov		  eax,DSPBufferSize
				mov		  edx,DSPChorus

				mov		  esi,DSPSourceBuffer
				mov		  edi,DSPDestBuffer

				mov		  ecx,dword ptr [edx+glxKNIChorus.time]
				mov		  TempEBP,eax

				movlps	  xmm0,[edx+glxKNIChorus.leftout]
				;

				movlps	  xmm2,[edx+glxKNIChorus.feedbackleft]
				;

				movlps	  xmm3,[edx+glxKNIChorus.wetleft]
				;

@@ChorusMainLoop:				
				;update delay buffer
				mulps	  xmm0,xmm2
				movlps	  xmm4,[esi]

				addps	  xmm0,xmm4
				add		  esi,8

				movlps	  dword ptr [edx+ecx*8+glxKNIChorus.buf01],xmm0

				;process first voice
				mov		  ebx,[edx+glxKNIChorus.phase0]
				;
				
				shr		  ebx,6
				;
				
				mov		  ebx,[edx+ebx*4+glxKNIChorus.wave]
				;
				
				sar		  ebx,15
				;
				
				add		  ebx,ecx
				;
				
				and		  ebx,3fffh
				;
				
				movlps	  xmm0,dword ptr [edx+ebx*8+glxKNIChorus.buf01]
				;

				;process second voice
				mov		  ebx,[edx+glxKNIChorus.phase1]
				;

				shr		  ebx,6
				;

				mov		  ebx,[edx+ebx*4+glxKNIChorus.wave]
				;

				sar		  ebx,15
				;

				add		  ebx,ecx
				;

				and		  ebx,3fffh
				;

				movlps	  xmm1,dword ptr [edx+ebx*8+glxKNIChorus.buf01]
				;

				;mix left/right
				shufps	  xmm0,xmm1,01000100b
				;
				
				movaps	  xmm1,xmm0
				;
				
				shufps	  xmm1,xmm0,00010001b
				;
				
				addps	  xmm0,xmm1
				;
								
				shufps	  xmm0,xmm0,00001000b
				;

				;update voice LFOs
				mov		  eax,[edx+glxKNIChorus.speed]
				;

				add		  [edx+glxKNIChorus.phase0],eax
				;

				add		  [edx+glxKNIChorus.phase1],eax
				;

				and		  [edx+glxKNIChorus.phase0],65535
				;

				and		  [edx+glxKNIChorus.phase1],65535
				;

				;Add to output (do dry/wet stuff)
				movaps	  xmm1,xmm0
				movlps	  xmm4,[edi]

				mulps     xmm1,xmm3
				inc		  ecx
				
				addps     xmm1,xmm4
				and		  ecx,3fffh
				
				movlps	  [edi],xmm1
				add		  edi,8

				dec		  TempEBP
				jnz		  @@ChorusMainLoop

				movlps	  [edx+glxKNIChorus.leftout],xmm0
				
				mov		  dword ptr [edx+glxKNIChorus.time],ecx
@@ChorusDone:
				emms		

				popad
				 
				ret
kniChorus		ENDP

;******************************************************************************
;Lightspeed ]I[ post process routines, KNI optimized, 32 bit input samples.
;******************************************************************************

kniConvert      PROC      NEAR C InBuffer: DWord, InCount: DWord, OutBuffer: DWord, Mode: Byte
                pushad

                mov       al,Mode						
                mov       esi,InBuffer

                mov       cl,al
                mov       edi,OutBuffer

                and       cl,1
                mov       ebp,InCount

                shl       ebp,cl
				jz		  @@ConvDone

				test	  al,2
				jnz		  @@16Bit

                test      al,128                        
                jz        @@8Bit

				mov       ebx,80808080h

				movd      mm5,ebx                       
                punpckldq mm5,mm5                       

@@8Bit:			test      al,64
				jz		  @@Conv8

@@Load8:		sub		  ebp,8h
			    js		  @@Load8End
@@Load8MainLoop:
				cvtps2pi  _mm0,dword ptr [esi]
				;

				cvtps2pi  _mm1,dword ptr [esi+8]
				;

				cvtps2pi  _mm2,dword ptr [esi+16]
				;

				cvtps2pi  _mm3,dword ptr [esi+24]
				packssdw  mm0,mm1
				
				paddsw	  mm0,qword ptr dither8
				;

				psraw	  mm0,8
				packssdw  mm2,mm3
				
				paddsw    mm2,qword ptr dither8
				;
				
				psraw	  mm2,8
				movq	  mm1,qword ptr [edi]

				packsswb  mm0,mm2
				psubb	  mm1,mm5
				
				paddsb    mm0,mm1
				;
				
				paddb	  mm0,mm5
				add		  esi,32
				
				movq	  qword ptr [edi],mm0
				add		  edi,8

				sub		  ebp,8h
				jns		  @@Load8MainLoop
@@Load8End:	
                add       ebp,8h-1h
                js        @@ConvDone
@@Load8EndLoop:
				cvtss2si  eax,dword ptr [esi]
				add	      esi,4
				
				movd	  mm0,eax
				;
				
				movsx	  eax,byte ptr [edi]
				;

				movd	  mm1,eax
				;
				
				paddsw	  mm0,qword ptr dither8
				;

				psraw	  mm0,8
				psubb	  mm1,mm5

				paddsb 	  mm0,mm1
				;

				paddb	  mm0,mm5
				;

				movd	  eax,mm0
				;
				
				mov       byte ptr [edi],al
				add       edi,1
				
				sub		  ebp,1h
				jns		  @@Load8EndLoop

@@Conv8:		sub		  ebp,8h
			    js		  @@Conv8End
@@Conv8MainLoop:
				cvtps2pi  _mm0,dword ptr [esi]
				;

				cvtps2pi  _mm1,dword ptr [esi+8]
				;

				cvtps2pi  _mm2,dword ptr [esi+16]
				;

				cvtps2pi  _mm3,dword ptr [esi+24]
				packssdw  mm0,mm1
				
				paddsw	  mm0,qword ptr dither8
				;

				psraw	  mm0,8
				packssdw  mm2,mm3
				
				paddsw    mm2,qword ptr dither8
				;
				
				psraw	  mm2,8
				;

				packsswb  mm0,mm2
				;

				paddb	  mm0,mm5
				add		  esi,32

				movq	  qword ptr [edi],mm0
				add		  edi,8

				sub		  ebp,8h
				jns		  @@Conv8MainLoop
@@Conv8End:	
                add       ebp,8h-1h
                js        @@ConvDone
@@Conv8EndLoop:
				cvtss2si  eax,dword ptr [esi]
				add	      esi,4
				
				movd	  mm0,eax
				;
				
				paddsw	  mm0,qword ptr dither8
				;

				psraw	  mm0,8
				;

				paddb	  mm0,mm5
				;

				movd	  eax,mm0
				;

				mov       byte ptr [edi],al
				add       edi,1
				
				sub		  ebp,1h
				jns		  @@Conv8EndLoop

				jmp		  @@ConvDone

@@16Bit:		test      al,64
				jz		  @@Conv16

@@Load16:	    sub		  ebp,8h
			    js		  @@Load16End
@@Load16MainLoop:
				cvtps2pi  _mm0,dword ptr [esi]
				;

				cvtps2pi  _mm1,dword ptr [esi+8]
				;

				cvtps2pi  _mm2,dword ptr [esi+16]
				;

				cvtps2pi  _mm3,dword ptr [esi+24]
				packssdw  mm0,mm1
				
				paddsw	  mm0,qword ptr [edi]
				;
				
				movq	  qword ptr [edi],mm0
				packssdw  mm2,mm3
				
				paddsw	  mm2,qword ptr [edi+8]
				add		  esi,32
				
				movq	  qword ptr [edi+8],mm2
				add		  edi,16

				sub		  ebp,8h
				jns		  @@Load16MainLoop
@@Load16End:	
                add       ebp,8h-1h
                js        @@ConvDone
@@Load16EndLoop:
				cvtss2si  eax,dword ptr [esi]
				add	      esi,4

				movd	  mm0,eax
				;

				movsx	  eax,word ptr [edi]
				;

				movd	  mm1,eax
				;
				
				packssdw  mm0,mm0
				;
				
				paddsw	  mm0,mm1
				;
								
				movd	  eax,mm0
				;

				mov       word ptr [edi],ax
				add       edi,2
				
				sub		  ebp,1h
				jns		  @@Load16EndLoop

				jmp		  @@ConvDone

@@Conv16:	    sub		  ebp,8h
			    js		  @@Conv16End
@@Conv16MainLoop:
				cvtps2pi  _mm0,dword ptr [esi]
				;

				cvtps2pi  _mm1,dword ptr [esi+8]
				;

				cvtps2pi  _mm2,dword ptr [esi+16]
				;

				cvtps2pi  _mm3,dword ptr [esi+24]
				packssdw  mm0,mm1
				
				packssdw  mm2,mm3
				;

				movq	  qword ptr [edi],mm0
				add		  esi,32
				
				movq	  qword ptr [edi+8],mm2
				add		  edi,16

				sub		  ebp,8h
				jns		  @@Conv16MainLoop
@@Conv16End:	
                add       ebp,8h-1h
                js        @@ConvDone
@@Conv16EndLoop:
				cvtss2si  eax,dword ptr [esi]
				add	      esi,4

				movd	  mm0,eax
				;

				packssdw  mm0,mm0
				;

				movd	  eax,mm0
				;

				mov       word ptr [edi],ax
				add       edi,2
				
				sub		  ebp,1h
				jns		  @@Conv16EndLoop

@@ConvDone:		emms

                popad

                ret
kniConvert      ENDP

kniConvertSize  equ       $-kniConvert

;******************************************************************************
;Lightspeed ]I[ mixing init. routines, KNI optimized.
;******************************************************************************

                PUBLIC C  kniMixerInit

kniMixerInit    PROC      NEAR C MixType: Byte,VolumeBase: DWord,MixerBase: DWord
                push      ebx
                push      ecx
                push      edx
                push      esi
                push      edi
                cld
                mov       eax,[VolumeBase]
                mov       ebx,[MixerBase]
                mov       ecx,kniMixerStereoSize
                mov       esi,offset kniMixerStereo
                mov       edi,ebx
                rep       movsb
                mov       eax,edi
                mov       ecx,kniConvertSize
                mov       esi,offset kniConvert
                rep       movsb
                pop       edi
                pop       esi
                pop       edx
                pop       ecx
                pop       ebx
                ret
kniMixerInit    ENDP

.DATA

ALIGN 16

DrySend			dd		  0,0,0,0
EffectASend		dd		  0,0,0,0
EffectBSend		dd		  0,0,0,0
FractionMask	dw		  7fffh,7fffh,7fffh,7fffh
FractionHold	dw		  7fffh,0000h,7fffh,0000h
SendScale		dd		  30800000h,30800000h,30800000h,30800000h				; 1/32768*1/32768
revoutsend		dd		  3f000000h,3f000000h,3f000000h,3f000000h				; 1/2
revoutsend2		dd		  3eaaaaabh,3eaaaaabh,3eaaaaabh,3eaaaaabh
dither8			dw		  0080h,0080h,0080h,0080h		  
TempEBP			dd		  0
TempESP			dd		  0

                END
