; ƒ- Internal revision no. 5.00b -ƒƒƒƒ Last revision at 14:01 on 24-06-1998 -ƒƒ
;
;                      The 32 bit x86-MMX Assembly source
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
; ≥ This source file, MMX.ASM    is Copyright (c) 1993-98 by Carlo Vogelsang. ≥
; ≥ You may not copy, distribute,  duplicate or clone this file  in any form, ≥
; ≥ modified or non-modified. It belongs to the author.  By copying this file ≥
; ≥ you are violating laws and will be punished. I will knock your brains in  ≥
; ≥ myself or you will be sued to death..                                     ≥
; ≥                                                                     Carlo ≥
; ¿ƒ( How the fuck did you get this file anyway? )ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
;
.586
.MMX
.MODEL          FLAT

.CODE

include			hdr\galaxy.ah

;*************************************************************************************
;Lightspeed ]I[ mixing routines, MMX optimized, 16 bit stereo, interpolated, dual efx.
;*************************************************************************************

mmxMixerStereo  PROC      NEAR C Dry: DWord, EffectA: DWord, EffectB: DWord, Count: DWord, SampleInt: DWord, SampleFrac: Word, PitchShift: DWord, LeftVolume: Word, RightVolume: Word, LeftEffectA: Word, RightEffectA: Word, LeftEffectB: Word, RightEffectB: Word, Mode: Byte
                pushad

                test      Mode,4                        ; Need surround ?
                jz        @@mmxNormal                   ; Nope ? Go on..

                neg       RightVolume                   ; 180 deg phase-shift
				neg	      RightEffectA					; 180 deg phase-shift

				neg		  RightEffectB					; 180 deg phase-shift
				;
@@mmxNormal:
				and		  SampleFrac,not 1				; Adjust for limited				
				and		  PitchShift,not 1				; fractional resolution

                ;Setup volumes in "volumes" (Right/Left/Right/Left)
                mov       ax,LeftVolume
                mov       bx,RightVolume
				
				mov		  word ptr DrySend,ax
				mov		  word ptr DrySend+4,ax
				
				mov		  word ptr DrySend+2,bx
				mov		  word ptr DrySend+6,bx
                				
                mov       ax,LeftEffectA
				mov       bx,RightEffectA
				
				mov		  word ptr EffectASend,ax
				mov		  word ptr EffectASend+4,ax
				
				mov		  word ptr EffectASend+2,bx
				mov		  word ptr EffectASend+6,bx

                mov       ax,LeftEffectB
				mov       bx,RightEffectB
				
				mov		  word ptr EffectBSend,ax
				mov		  word ptr EffectBSend+4,ax
				
				mov		  word ptr EffectBSend+2,bx
				mov		  word ptr EffectBSend+6,bx

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

                movq      mm5,FractionMask              ; Setup fraction mask
                psraw     mm4,1							; 15 bit steps in MM4

;               test      Mode,2                        ; Need filtering ?
;               jnz       @@mmxFilter                   ; Yope ? Use it..

;               movq      mm3,FractionHold              ; Setup fractions in MM3
;               pxor      mm4,mm4                       ; Clear MM4 (Steps)
@@mmxFilter:    
				test      Mode,1                        ; Need 16 bit mixing ?
                jnz       @@Mix16                       ; Yope ? Do it..

;******************************************************************************
;Lightspeed ]I[ mixing routines, MMX optimized, 8 bit input samples.
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

                movd      mm6,ecx
				;

                mov       ch,[esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				;

                movd      mm7,ecx
				;
			
                adc       esi,ebp
                punpckldq mm6,mm7

				pmaddwd	  mm6,mm3
				paddw	  mm3,mm4
				
				psrad	  mm6,15
				paddw     mm3,mm4

				packssdw  mm6,mm6
				pand	  mm3,mm5

				punpcklwd mm6,mm6
                test      edi,7
				
				movq	  mm0,mm6
                jz        @@Mix8MainEnd

                mov       ch,[esi]
				movq	  mm6,mm7

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				psubw	  mm3,mm4

                movd      mm7,ecx
				pand	  mm3,mm5
                
				adc       esi,ebp
				punpckldq mm6,mm7

				pmaddwd	  mm6,mm3
				movq	  mm1,mm0

				pmulhw    mm0,DrySend
				movq	  mm2,mm1

				pmulhw    mm1,EffectASend
				paddw	  mm3,mm4
				
				pmulhw    mm2,EffectBSend
				paddw	  mm3,mm4

				paddsw    mm0,[edi]
				pand      mm3,mm5

				paddsw    mm1,[eax]
				psrad	  mm6,15

				paddsw    mm2,[ebx]
				packssdw  mm6,mm6
				
				movd	  [edi],mm0
				punpcklwd mm6,mm6

				movd	  [eax],mm1
				movq	  mm0,mm6

				movd	  [ebx],mm2
				;

				add		  eax,4
				add		  ebx,4
				
				sub		  dx,1h
				add       edi,4

                sub       dx,4h
                js        @@Mix8End
@@Mix8MainLoop:
                mov       ch,[esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				;

                adc       esi,ebp
				;

                movd      mm6,ecx
				;

                mov       ch,[esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				;

                movd      mm7,ecx
				;
			
                adc       esi,ebp
                punpckldq mm6,mm7
							
				pmaddwd	  mm6,mm3
				movq	  mm1,mm0

				pmulhw    mm0,DrySend
				movq	  mm2,mm1

				pmulhw    mm1,EffectASend
				paddw	  mm3,mm4
				
				pmulhw    mm2,EffectBSend
				paddw	  mm3,mm4

				paddsw    mm0,[edi]
				pand      mm3,mm5

				paddsw    mm1,[eax]
				psrad	  mm6,15

				paddsw    mm2,[ebx]
				packssdw  mm6,mm6
				
				movq	  [edi],mm0
				punpcklwd mm6,mm6

				movq	  [eax],mm1
				movq	  mm0,mm6

				movq	  [ebx],mm2
				;

                mov       ch,[esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				;

                adc       esi,ebp
				;

                movd      mm6,ecx
				;

                mov       ch,[esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				;

                movd      mm7,ecx
				;
			
                adc       esi,ebp
                punpckldq mm6,mm7
							
				pmaddwd	  mm6,mm3
				movq	  mm1,mm0

				pmulhw    mm0,DrySend
				movq	  mm2,mm1

				pmulhw    mm1,EffectASend
				paddw	  mm3,mm4
				
				pmulhw    mm2,EffectBSend
				paddw	  mm3,mm4

				paddsw    mm0,[edi+8]
				pand      mm3,mm5

				paddsw    mm1,[eax+8]
				psrad	  mm6,15

				paddsw    mm2,[ebx+8]
				packssdw  mm6,mm6
				
				movq	  [edi+8],mm0
				punpcklwd mm6,mm6

				movq	  [eax+8],mm1
				movq	  mm0,mm6

				movq	  [ebx+8],mm2
				;

				add		  eax,16
				add		  ebx,16
				
				add       edi,16
				;
@@Mix8MainEnd:
                sub       dx,4h
                jns       @@Mix8MainLoop
@@Mix8End:
				add       dx,4h-1h
                js        @@MixDone
@@Mix8EndLoop:
                mov       ch,[esi]
				movq	  mm6,mm7

                shl       ecx,16
                add       edx,esp

                mov       ch,[esi+1]
				psubw	  mm3,mm4

                movd      mm7,ecx
				pand	  mm3,mm5
				
				punpckldq mm6,mm7
				movq	  mm1,mm0

                adc       esi,ebp
				pmaddwd	  mm6,mm3

				pmulhw    mm0,DrySend
				movq	  mm2,mm1

				pmulhw    mm1,EffectASend
				paddw	  mm3,mm4
				
				pmulhw    mm2,EffectBSend
				paddw	  mm3,mm4

				paddsw    mm0,[edi]
				pand      mm3,mm5

				paddsw    mm1,[eax]
				psrad	  mm6,15

				paddsw    mm2,[ebx]
				packssdw  mm6,mm6
				
				movd	  [edi],mm0
				punpcklwd mm6,mm6

				movd	  [eax],mm1
				movq	  mm0,mm6

				movd	  [ebx],mm2
				;

				add		  eax,4
				add		  ebx,4

				add		  edi,4
				;

                sub       dx,1h
                jns       @@Mix8EndLoop

				jmp		  @@MixDone

;******************************************************************************
;Lightspeed ]I[ mixing routines, MMX optimized, 16 bit input samples.
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
				xor		  ecx,ecx

                mov       cx,[esi+esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				;

                adc       esi,ebp
				;

                movd      mm6,ecx
				;

                mov       cx,[esi+esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				;

                movd      mm7,ecx
				;
			
                adc       esi,ebp
                punpckldq mm6,mm7

				pmaddwd	  mm6,mm3
				paddw	  mm3,mm4
				
				psrad	  mm6,15
				paddw     mm3,mm4

				packssdw  mm6,mm6
				pand	  mm3,mm5

				punpcklwd mm6,mm6
                test      edi,7
				
				movq	  mm0,mm6
                jz        @@Mix16MainEnd

                mov       cx,[esi+esi]
				movq	  mm6,mm7

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				psubw	  mm3,mm4

                movd      mm7,ecx
				pand	  mm3,mm5
                
				adc       esi,ebp
				punpckldq mm6,mm7

				pmaddwd	  mm6,mm3
				movq	  mm1,mm0

				pmulhw    mm0,DrySend
				movq	  mm2,mm1

				pmulhw    mm1,EffectASend
				paddw	  mm3,mm4
				
				pmulhw    mm2,EffectBSend
				paddw	  mm3,mm4

				paddsw    mm0,[edi]
				pand      mm3,mm5

				paddsw    mm1,[eax]
				psrad	  mm6,15

				paddsw    mm2,[ebx]
				packssdw  mm6,mm6
				
				movd	  [edi],mm0
				punpcklwd mm6,mm6

				movd	  [eax],mm1
				movq	  mm0,mm6

				movd	  [ebx],mm2
				;

				add		  eax,4
				add		  ebx,4
				
				sub		  dx,1h
				add       edi,4

                sub       dx,4h
                js        @@Mix16End
@@Mix16MainLoop:
                mov       cx,[esi+esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				;

                adc       esi,ebp
				;

                movd      mm6,ecx
				;

                mov       cx,[esi+esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				;

                movd      mm7,ecx
				;
			
                adc       esi,ebp
                punpckldq mm6,mm7
							
				pmaddwd	  mm6,mm3
				movq	  mm1,mm0

				pmulhw    mm0,DrySend
				movq	  mm2,mm1

				pmulhw    mm1,EffectASend
				paddw	  mm3,mm4
				
				pmulhw    mm2,EffectBSend
				paddw	  mm3,mm4

				paddsw    mm0,[edi]
				pand      mm3,mm5

				paddsw    mm1,[eax]
				psrad	  mm6,15

				paddsw    mm2,[ebx]
				packssdw  mm6,mm6
				
				movq	  [edi],mm0
				punpcklwd mm6,mm6

				movq	  [eax],mm1
				movq	  mm0,mm6

				movq	  [ebx],mm2
				;

                mov       cx,[esi+esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				;

                adc       esi,ebp
				;

                movd      mm6,ecx
				;

                mov       cx,[esi+esi]
				;

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				;

                movd      mm7,ecx
				;
			
                adc       esi,ebp
                punpckldq mm6,mm7
							
				pmaddwd	  mm6,mm3
				movq	  mm1,mm0

				pmulhw    mm0,DrySend
				movq	  mm2,mm1

				pmulhw    mm1,EffectASend
				paddw	  mm3,mm4
				
				pmulhw    mm2,EffectBSend
				paddw	  mm3,mm4

				paddsw    mm0,[edi+8]
				pand      mm3,mm5

				paddsw    mm1,[eax+8]
				psrad	  mm6,15

				paddsw    mm2,[ebx+8]
				packssdw  mm6,mm6
				
				movq	  [edi+8],mm0
				punpcklwd mm6,mm6

				movq	  [eax+8],mm1
				movq	  mm0,mm6

				movq	  [ebx+8],mm2
				;

				add		  eax,16
				add		  ebx,16
				
				add       edi,16
				;
@@Mix16MainEnd:
                sub       dx,4h
                jns       @@Mix16MainLoop
@@Mix16End:
                add       dx,4h-1h
                js        @@MixDone
@@Mix16EndLoop:
                mov       cx,[esi+esi]
				movq	  mm6,mm7

                shl       ecx,16
                add       edx,esp

                mov       cx,[esi+esi+2]
				psubw	  mm3,mm4

                movd      mm7,ecx
				pand	  mm3,mm5
				
				punpckldq mm6,mm7
				movq	  mm1,mm0

                adc       esi,ebp
				pmaddwd	  mm6,mm3

				pmulhw    mm0,DrySend
				movq	  mm2,mm1

				pmulhw    mm1,EffectASend
				paddw	  mm3,mm4
				
				pmulhw    mm2,EffectBSend
				paddw	  mm3,mm4

				paddsw    mm0,[edi]
				pand      mm3,mm5

				paddsw    mm1,[eax]
				psrad	  mm6,15

				paddsw    mm2,[ebx]
				packssdw  mm6,mm6
				
				movd	  [edi],mm0
				punpcklwd mm6,mm6

				movd	  [eax],mm1
				movq	  mm0,mm6

				movd	  [ebx],mm2
				;

				add		  eax,4
				add		  ebx,4

				add		  edi,4
				;

                sub       dx,1h
                jns       @@Mix16EndLoop

@@MixDone:      mov		  esp,TempESP

				emms
				
				popad

                ret
mmxMixerStereo  ENDP

mmxMixerStereoSize equ    $-mmxMixerStereo

;******************************************************************************
;Lightspeed ]I[ digital effects routine, MMX optimized, 16 bit input samples.
;******************************************************************************

mmxReverb		PROC	  NEAR C DSPReverb: DWord, DSPDestBuffer: DWord, DSPSourceBuffer, DSPBufferSize: DWord, Flags: DWord
				pushad

				mov		  eax,DSPBufferSize
				mov		  edx,DSPReverb

				mov		  esi,DSPSourceBuffer
				mov		  edi,DSPDestBuffer

				mov		  ecx,dword ptr [edx+glxMMXReverb.time]
				mov		  TempEBP,eax

				movd	  mm0,dword ptr [edx+glxMMXReverb.leftout]
				;

				movd	  mm4,dword ptr [edx+glxMMXReverb.apf0lpfout]
				;

				movd	  mm5,dword ptr [edx+glxMMXReverb.apf2lpfout]
				;

				movd	  mm6,dword ptr [edx+glxMMXReverb.apf4lpfout]
				;

				mov       ebp,[edx+glxMMXReverb.td1]
				;

				lea		  ebx,[ecx+ebp]
				;

				and		  ebx,3fffh
				mov		  ebp,[edx+glxMMXReverb.td0]

				mov		  ax,word ptr [edx+ebx*4+glxMMXReverb.buf01+2]
				lea		  ebx,[ecx+ebp]

				shl		  eax,16
				and		  ebx,3fffh

				mov		  ax,word ptr [edx+ebx*4+glxMMXReverb.buf01]
@@ReverbMainLoop:				
				movq      mm1,mm0
				psrlq	  mm0,16

				movd      mm2,dword ptr [esi]
				punpckldq mm0,mm1

				paddsw	  mm0,mm2
				add		  esi,4

				movd      mm1,eax
				psraw	  mm0,1

				;Update one allpass filter for left and right
				mov       ebp,dword ptr [edx+glxMMXReverb.td3]
				nop

				movq	  mm2,mm1
				punpcklwd mm1,mm0

				punpcklwd mm2,mm4
				lea		  ebx,[ecx+ebp]

				pmaddwd   mm1,qword ptr [edx+glxMMXReverb.apf0gain2]
				and		  ebx,3fffh

				pmaddwd	  mm2,qword ptr [edx+glxMMXReverb.apf0lpfa]
				mov		  ebp,dword ptr [edx+glxMMXReverb.td2]

				mov		  ax,word ptr [edx+ebx*4+glxMMXReverb.buf23+2]
				nop

				psrad	  mm1,15
				lea		  ebx,[ecx+ebp]

				psrad	  mm2,15
				and		  ebx,3fffh

				shl		  eax,16
				packssdw  mm1,mm1

				mov		  ax,word ptr [edx+ebx*4+glxMMXReverb.buf23]
				packssdw  mm2,mm2

				paddsw    mm0,mm2
				movq      mm3,mm1
				
				movd      mm1,eax
				movq      mm4,mm2

				movd	  dword ptr [edx+ecx*4+glxMMXReverb.buf01],mm0
				movq	  mm0,mm3

				;Update one allpass filter for left and right
				mov       ebp,dword ptr [edx+glxMMXReverb.td5]
				nop

				movq	  mm2,mm1
				punpcklwd mm1,mm0

				punpcklwd mm2,mm4
				lea		  ebx,[ecx+ebp]

				pmaddwd   mm1,qword ptr [edx+glxMMXReverb.apf2gain2]
				and		  ebx,3fffh

				pmaddwd	  mm2,qword ptr [edx+glxMMXReverb.apf2lpfa]
				mov		  ebp,dword ptr [edx+glxMMXReverb.td4]

				mov		  ax,word ptr [edx+ebx*4+glxMMXReverb.buf45+2]
				nop

				psrad	  mm1,15
				lea		  ebx,[ecx+ebp]

				psrad	  mm2,15
				and		  ebx,3fffh

				shl		  eax,16
				packssdw  mm1,mm1

				mov		  ax,word ptr [edx+ebx*4+glxMMXReverb.buf45]
				packssdw  mm2,mm2

				paddsw    mm0,mm2
				movq      mm3,mm1
				
				movd      mm1,eax
				movq      mm4,mm2

				movd	  dword ptr [edx+ecx*4+glxMMXReverb.buf23],mm0
				movq	  mm0,mm3

				;Update one allpass filter for left and right
				mov       ebp,dword ptr [edx+glxMMXReverb.td1]
				nop

				movq	  mm2,mm1
				punpcklwd mm1,mm0

				punpcklwd mm2,mm4
				lea		  ebx,[ecx+ebp]

				pmaddwd   mm1,qword ptr [edx+glxMMXReverb.apf4gain2]
				and		  ebx,3fffh

				pmaddwd	  mm2,qword ptr [edx+glxMMXReverb.apf4lpfa]
				mov		  ebp,dword ptr [edx+glxMMXReverb.td0]

				mov		  ax,word ptr [edx+ebx*4+glxMMXReverb.buf01+2]
				nop

				psrad	  mm1,15
				lea		  ebx,[ecx+ebp]

				psrad	  mm2,15
				and		  ebx,3fffh

				shl		  eax,16
				packssdw  mm1,mm1

				mov		  ax,word ptr [edx+ebx*4+glxMMXReverb.buf01]
				packssdw  mm2,mm2

				paddsw    mm0,mm2
				movq      mm3,mm1
				
				movd      mm1,eax
				movq      mm4,mm2

				movd	  dword ptr [edx+ecx*4+glxMMXReverb.buf45],mm0
				movq	  mm0,mm3
			
				;Add to output (do dry/wet stuff)

				movd	  mm7,dword ptr [edi]

				punpcklwd mm7,mm0

				pmaddwd   mm7,qword ptr [edx+glxMMXReverb.dryleft]

				psrad	  mm7,15
				inc		  ecx

				packssdw  mm7,mm7
				and		  ecx,3fffh

				movd	  dword ptr [edi],mm7
				add		  edi,4

				dec		  TempEBP
				jnz		  @@ReverbMainLoop

				mov		  dword ptr [edx+glxMMXReverb.time],ecx
				;

				movd	  dword ptr [edx+glxMMXReverb.leftout],mm0
				;

				movd	  dword ptr [edx+glxMMXReverb.apf0lpfout],mm4
				;

				movd	  dword ptr [edx+glxMMXReverb.apf2lpfout],mm5
				;

				movd	  dword ptr [edx+glxMMXReverb.apf4lpfout],mm6
				;
@@ReverbDone:
				emms		

				popad
				 
				ret
mmxReverb		ENDP

;******************************************************************************
;Lightspeed ]I[ digital effects routine, MMX optimized, 16 bit input samples.
;******************************************************************************

mmxChorus		PROC	  NEAR C DSPChorus: DWord, DSPDestBuffer: DWord, DSPSourceBuffer, DSPBufferSize: DWord, Flags: DWord
				pushad

				mov		  eax,DSPBufferSize
				mov		  edx,DSPChorus

				mov		  esi,DSPSourceBuffer
				mov		  edi,DSPDestBuffer

				mov		  ecx,dword ptr [edx+glxMMXChorus.time]
				mov		  TempEBP,eax

				movd	  mm0,dword ptr [edx+glxMMXChorus.leftout]

				movd	  mm2,dword ptr [edx+glxMMXChorus.feedbackleft]
@@ChorusMainLoop:				
				;update delay buffer
				movd      mm1,dword ptr [esi]
				pmulhw    mm0,mm2

				;
				;

				;
				;

				paddsw    mm0,mm0
				;

				paddsw	  mm0,mm1
				;

				movd	  dword ptr [edx+ecx*4+glxMMXChorus.buf01],mm0
				;
				
				add		  esi,4
				;
				
				;process first voice
				mov		  ebx,[edx+glxMMXChorus.phase0]
				;
				
				shr		  ebx,6
				;
				
				mov		  ebx,[edx+ebx*4+glxMMXChorus.wave]
				;
				
				sar		  ebx,15
				;
				
				add		  ebx,ecx
				;
				
				and		  ebx,3fffh
				;
				
				movd	  mm0,dword ptr [edx+ebx*4+glxMMXChorus.buf01]
				;

				;process second voice
				mov		  ebx,[edx+glxMMXChorus.phase1]
				;

				shr		  ebx,6
				;

				mov		  ebx,[edx+ebx*4+glxMMXChorus.wave]
				;

				sar		  ebx,15
				;

				add		  ebx,ecx
				;

				and		  ebx,3fffh
				;

				movd	  mm1,dword ptr [edx+ebx*4+glxMMXChorus.buf01]
				;

				;mix left/right
				punpcklwd mm0,mm1
				;

				movq	  mm1,mm0
				;
				
				psrlq	  mm0,32
				;

				paddsw	  mm0,mm1
				;
				
				;update voice LFOs
				mov		  eax,[edx+glxMMXChorus.speed]
				;

				add		  [edx+glxMMXChorus.phase0],eax
				;

				add		  [edx+glxMMXChorus.phase1],eax
				;

				and		  [edx+glxMMXChorus.phase0],65535
				;

				and		  [edx+glxMMXChorus.phase1],65535
				;
				
				;Add to output (do dry/wet stuff)
				movd	  mm1,dword ptr [edi]
				;

				punpcklwd mm1,mm0
				;

				pmaddwd   mm1,qword ptr [edx+glxMMXChorus.dryleft]
				;

				psrad	  mm1,15
				inc		  ecx

				packssdw  mm1,mm1
				and		  ecx,3fffh

				movd	  dword ptr [edi],mm1
				add		  edi,4

				dec		  TempEBP
				jnz		  @@ChorusMainLoop

				movd	  dword ptr [edx+glxMMXChorus.leftout],mm0

				mov		  dword ptr [edx+glxMMXChorus.time],ecx
@@ChorusDone:
				emms		

				popad
				 
				ret
mmxChorus		ENDP

;******************************************************************************
;Lightspeed ]I[ post process routines, MMX optimized, 16 bit input samples.
;******************************************************************************

mmxConvert      PROC      NEAR C InBuffer: DWord, InCount: DWord, OutBuffer: DWord, Mode: Byte
                pushad

                mov       al,Mode						
                mov       esi,InBuffer

                mov       cl,al
                mov       edi,OutBuffer

                and       cl,1
                mov       ebp,InCount

                shl       ebp,cl
      			mov       ebx,7fff7fffh                 ; Can't do immediate

				test	  ebp,ebp
				jz		  @@Conv16Done

				movd      mm4,ebx                       ; Setup mono balance
				
                punpckldq mm4,mm4                       ; in MM4..
                xor       ebx,ebx

                test      al,128                        ; unsigned ?
                jz        @@okthen

                mov       ebx,80808080h                 ; Can't do immediate

@@okthen:       movd      mm5,ebx                       ; Setup fractions
                punpckldq mm5,mm5                       ; in MM5..

				test	  al,64							; Add to output ?
				jz		  @@okthen2	

				push	  eax 
				push	  ebp
		
			    xor		  ecx,ecx						; Source
				xor		  edx,edx						; Dest

				test	  al,2							; 16 bit output ?								
				jnz		  @@loadbuffer16	

				xor		  eax,eax

@@loadbuffer8:	sub		  ebp,4h
			    js		  @@load8end

@@load8main:	movd      mm0,dword ptr [edi+ecx]
				pxor	  mm1,mm1

				pxor	  mm0,mm5
				add		  ecx,4
				
				punpcklbw mm1,mm0
				;nop				

				psraw	  mm1,1
				;

				paddsw	  mm1,[esi+edx]
				;nop

				movq	  [esi+edx],mm1
				add		  edx,8

				sub		  ebp,4h
				jns		  @@load8main

@@load8end:		add		  ebp,4h
				jz		  @@loaddone
				
@@load8endmain: xor		  eax,eax
				mov		  ah,byte ptr [edi+ecx]
			    			
				xor		  ah,bh
				add		  ecx,1
				
				movd 	  mm1,eax
				;nop
				
                mov		  ax,word ptr [esi+edx]
				;nop
				
				movd      mm0,eax
                ;nop

				psraw	  mm1,1
				;
				
				paddsw	  mm1,mm0
				;nop

				movd 	  eax,mm1
				;nop
									
				mov		  word ptr [esi+edx],ax
				add		  edx,2

				sub		  ebp,1h
				jnz		  @@load8endmain				 

				jmp		  @@loaddone

@@loadbuffer16:	sub		  ebp,4h
				js		  @@load16end

@@load16main:	movq	  mm0,[edi+ecx]	
         		add		  ecx,8

				psraw	  mm0,1
				;nop

				paddsw	  mm0,[esi+edx]
				;nop

				movq	  [esi+edx],mm0
				add		  edx,8	
		
				sub		  ebp,4h
				jns		  @@load16main

@@load16end:	add		  ebp,4h
				jz		  @@loaddone
				
@@load16endmain:mov		  ax,word ptr [edi+ecx]
			    add		  ecx,2
				
				movd 	  mm0,eax
				;nop
			
                mov		  ax,word ptr [esi+edx]
				;nop
				
				movd      mm1,eax
                ;nop

				psraw	  mm0,1
				;nop
				
				paddsw	  mm0,mm1
				;nop

				movd 	  eax,mm0
				;nop
									
				mov		  word ptr [esi+edx],ax
				add		  edx,2

				sub		  ebp,1h
				jnz		  @@load16endmain

@@loaddone:		pop		  ebp 
				pop		  eax

@@okthen2:      test      al,2
                jz        @@Conv16Main3

                test      al,1
                jnz       @@Conv16Main2
@@Conv16Main1:
                sub       ebp,8h
                js        @@Conv16End1
@@Conv16MainLoop1:
                movq      mm0,[esi]

                movq      mm1,[esi+8]
                pmaddwd   mm0,mm4

                movq      mm2,[esi+16]
                pmaddwd   mm1,mm4

                movq      mm3,[esi+24]
                pmaddwd   mm2,mm4

                psrad     mm0,15
                pmaddwd   mm3,mm4

                psrad     mm1,15
                add       esi,32

                packssdw  mm0,mm1
                psrad     mm2,15

                movq      [edi],mm0
                psrad     mm3,15

                packssdw  mm2,mm3

                movq      [edi+8],mm2

                add       edi,16

                sub       ebp,8h
                jns       @@Conv16MainLoop1
@@Conv16End1:
                add       ebp,8h-1h
                js        @@Conv16Done
@@Conv16EndLoop1:
                mov       eax,dword ptr [esi]
                add       esi,4

                movd      mm0,eax

                pmaddwd   mm0,mm4

                psrad     mm0,15

                movd      eax,mm0

                mov       word ptr [edi],ax
                add       edi,2

                sub       ebp,1h
                jns       @@Conv16EndLoop1

                jmp       @@Conv16Done

@@Conv16Main2:
                sub       ebp,8h
                js        @@Conv16End2
@@Conv16MainLoop2:
                movq      mm0,[esi]

                movq      mm1,[esi+8]
				paddsw	  mm0,mm0

                movq      [edi],mm0
				paddsw	  mm1,mm1

                movq      [edi+8],mm1

                add       esi,16
                add       edi,16

                sub       ebp,8h
                jns       @@Conv16MainLoop2
@@Conv16End2:
                add       ebp,8h-1h
                js        @@Conv16Done
@@Conv16EndLoop2:
                mov       ax,word ptr [esi]
                add       esi,2

				movd      mm0,eax

				paddsw	  mm0,mm0
				
				movd	  eax,mm0

                mov       word ptr [edi],ax
                add       edi,2

                sub       ebp,1h
                jns       @@Conv16EndLoop2

                jmp       @@Conv16Done

@@Conv16Main3:
                test      al,1
                jnz       @@Conv16Main4

                sub       ebp,8h
                js        @@Conv16End3
@@Conv16MainLoop3:
                movq      mm0,[esi]

                movq      mm1,[esi+8]
                pmaddwd   mm0,mm4

                movq      mm2,[esi+16]
                pmaddwd   mm1,mm4

                movq      mm3,[esi+24]
                pmaddwd   mm2,mm4

                psrad     mm0,15+8
                pmaddwd   mm3,mm4

                psrad     mm1,15+8
                add       esi,32

                packssdw  mm0,mm1
                psrad     mm2,15+8

                psrad     mm3,15+8

                packssdw  mm2,mm3

                packsswb  mm0,mm2

                pxor      mm0,mm5

                movq      [edi],mm0

                add       edi,8

                sub       ebp,8h
                jns       @@Conv16MainLoop3
@@Conv16End3:
                add       ebp,8h-1h
                js        @@Conv16Done
@@Conv16EndLoop3:
                mov       eax,dword ptr [esi]
                add       esi,4

                movd      mm0,eax

                pmaddwd   mm0,mm4

                psrad     mm0,15+8

                movd      eax,mm0

                xor       al,80h

                mov       byte ptr [edi],al
                add       edi,1

                sub       ebp,1h
                jns       @@Conv16EndLoop3

                jmp       @@Conv16Done

@@Conv16Main4:
                sub       ebp,8h
                js        @@Conv16End4
@@Conv16MainLoop4:
                movq      mm0,[esi]

                movq      mm1,[esi+8]
                psraw     mm0,7

                psraw     mm1,7

                packsswb  mm0,mm1
                add       esi,16

                pxor      mm0,mm5

                movq      [edi],mm0

                add       edi,8

                sub       ebp,8h
                jns       @@Conv16MainLoop4
@@Conv16End4:
                add       ebp,8h-1h
                js        @@Conv16Done
@@Conv16EndLoop4:
                movd      eax,mm5

                mov       al,byte ptr [esi+1]
                add       esi,2

				add		  al,al
				;

                xor       al,ah
				;

                mov       byte ptr [edi],al
                add       edi,1

                sub       ebp,1h
                jns       @@Conv16EndLoop4

@@Conv16Done:   emms

                popad

                ret
mmxConvert      ENDP

mmxConvertSize  equ       $-mmxConvert

;******************************************************************************
;Lightspeed ]I[ mixing init. routines, MMX optimized.
;******************************************************************************

                PUBLIC C  mmxMixerInit

mmxMixerInit    PROC      NEAR C MixType: Byte,VolumeBase: DWord,MixerBase: DWord
                push      ebx
                push      ecx
                push      edx
                push      esi
                push      edi
                cld
                mov       eax,[VolumeBase]
                mov       ebx,[MixerBase]
                mov       ecx,mmxMixerStereoSize
                mov       esi,offset mmxMixerStereo
                mov       edi,ebx
                rep       movsb
                mov       eax,edi
                mov       ecx,mmxConvertSize
                mov       esi,offset mmxConvert
                rep       movsb
                pop       edi
                pop       esi
                pop       edx
                pop       ecx
                pop       ebx
                ret
mmxMixerInit    ENDP

;******************************************************************************
;Lightspeed ]I[ digital effects routines, x86 optimized, 16 bit input samples.
;******************************************************************************

mmxEffect		PROC	  NEAR C DSPEffect: DWord, DSPDestBuffer: DWord, DSPSourceBuffer, DSPBufferSize: DWord, Flags: DWord
				pushad

				mov		  esi,DSPSourceBuffer
				mov		  edi,DSPDestBuffer

				mov		  ebx,DSPBufferSize
				mov		  edx,DSPEffect

				mov		  ebp,[edx+glxEffect.Time]

                push	  ebx
				push      dword ptr [edx+glxEffect.LPFOut]

                cmp       ebx,0
                je        @@EffectsDone

                movd      mm3,dword ptr [edx+glxEffect.Delay1Gain]

                movd      mm0,dword ptr [edx+glxEffect.Delay3Gain]

                movd      mm4,dword ptr [edx+glxEffect.Delay5Gain]

				mov		  ebx,dword ptr [edx+glxEffect.Delay2]
                punpckldq mm3,mm0

                movd      mm5,dword ptr [edx+glxEffect.LPF]

                movd      mm6,dword ptr [edx+glxEffect.Volume]
@@EffectsLoop:
                lea       ecx,[ebp+ebx]                 ; ECX=Pos in buffer
				mov		  ebx,dword ptr [edx+glxEffect.Delay1]

                and       ecx,07fffh                    ; Keep in buffer

                mov       ax,word ptr [ecx*2+edx+glxEffect.Buffer]

                shl       eax,16
                lea       ecx,[ebp+ebx]                 ; ECX=Pos in buffer

				mov		  ebx,dword ptr [edx+glxEffect.Delay4]
                and       ecx,07fffh                    ; Keep in buffer

                mov       ax,word ptr [ecx*2+edx+glxEffect.Buffer]

                movd      mm1,eax

                lea       ecx,[ebp+ebx]                 ; ECX=Pos in buffer
				mov		  ebx,dword ptr [edx+glxEffect.Delay3]
                
				and       ecx,07fffh                    ; Keep in buffer

                mov       ax,word ptr [ecx*2+edx+glxEffect.Buffer]

                shl       eax,16
                lea       ecx,[ebp+ebx]				    ; ECX=Pos in buffer

				mov		  ebx,dword ptr [edx+glxEffect.Delay6]
                and       ecx,07fffh                    ; Keep in buffer

                mov       ax,word ptr [ecx*2+edx+glxEffect.Buffer]

                movd      mm2,eax

                punpckldq mm1,mm2
                lea       ecx,[ebp+ebx]                  ; ECX=Pos in buffer
				mov		  ebx,dword ptr [edx+glxEffect.Delay5]

                and       ecx,07fffh                    ; Keep in buffer

                mov       ax,word ptr [ecx*2+edx+glxEffect.Buffer]

                shl       eax,16
                lea       ecx,[ebp+ebx]                 ; ECX=Pos in buffer

				mov		  ebx,dword ptr [edx+glxEffect.Delay2]
                and       ecx,07fffh                    ; Keep in buffer

                mov       ax,word ptr [ecx*2+edx+glxEffect.Buffer]

                movd      mm2,eax

                ;mm1=3210/mm2=xx54

                pmaddwd   mm1,mm3

                pmaddwd   mm2,mm4

                paddd     mm2,mm1
                psrlq     mm1,32

                paddd     mm2,mm1

                psrad     mm2,12

                packssdw  mm2,mm2

                ;mm2=effects output

                movd      eax,mm2

                shl       eax,16

                mov       ax,word ptr [esp]

                movd      mm2,eax

                pmaddwd   mm2,mm5

                psrad     mm2,15

                punpcklwd mm2,mm2

                movd      dword ptr [esp],mm2

                movd      mm1,dword ptr [esi]

                paddsw    mm1,mm2

;                movd      mm7,dword ptr [edi]

;                paddsw    mm7,mm1

                movd      dword ptr [edi],mm1

                movd      mm1,dword ptr [esi]

                paddsw    mm2,mm1

                psrld     mm1,16

                paddsw    mm2,mm1

                pmaddwd   mm2,mm6

                psrad     mm2,15

                movd      eax,mm2

                mov       word ptr [ebp*2+edx+glxEffect.Buffer],ax
                inc       ebp

                and       ebp,07fffh

                add       esi,4
                add       edi,4

                dec       dword ptr [esp+4]
                jnz       @@EffectsLoop
@@EffectsDone:
				pop       dword ptr [edx+glxEffect.LPFOut]
				pop		  ebx

				mov		  [edx+glxEffect.Time],ebp

                emms

				popad

                ret
mmxEffect       ENDP

.DATA

TempEBP			dd		  0
TempESP			dd		  0

DrySend			dq		  0
EffectASend		dq		  0
EffectBSend		dq		  0
FractionMask	dq		  07fff7fff7fff7fffh
FractionHold	dq		  07fff00007fff0000h

                END
