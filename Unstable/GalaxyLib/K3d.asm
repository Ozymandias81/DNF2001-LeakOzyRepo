; ƒ- Internal revision no. 5.00b -ƒƒƒƒ Last revision at 14:01 on 31-03-1999 -ƒƒ
;
;                    The 32 bit x86-3DNow! Assembly source
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
; ≥ This source file, K3D.ASM    is Copyright (c) 1993-99 by Carlo Vogelsang. ≥
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

include			hdr\galaxy.ah

;***************************************************************************************
;Lightspeed ]I[ mixing routines, 3DNow! optimized, 32 bit stereo, interpolated, dual efx
;***************************************************************************************

k3dMixerStereo  PROC      NEAR C Dry: DWord, EffectA: DWord, EffectB: DWord, Count: DWord, SampleInt: DWord, SampleFrac: Word, PitchShift: DWord, LeftVolume: Word, RightVolume: Word, LeftEffectA: Word, RightEffectA: Word, LeftEffectB: Word, RightEffectB: Word, Mode: Byte
                pushad

                test      Mode,4                        ; Need surround ?
                jz        @@k3dNormal                   ; Nope ? Go on..

                neg       RightVolume                   ; 180 deg phase-shift
				neg	      RightEffectA					; 180 deg phase-shift

				neg		  RightEffectB					; 180 deg phase-shift
				;
@@k3dNormal:
				and		  SampleFrac,not 1				; Adjust for limited				
				and		  PitchShift,not 1				; fractional resolution

                ;Setup volumes in "volumes" (Right/Left/Right/Left)
                movsx     eax,LeftVolume				; Get 15 bit L/R Vols
				movd	  mm0,eax
                movsx     eax,RightVolume
                movd      mm1,eax                       
				punpckldq mm0,mm1						; MM3 = RightVol LeftVol
				pi2fd	  mm0,mm0						; Convert to float
				pfmul     mm0,qword ptr SendScale 		; Multiply by 1/32768*1/32768
				movq	  DrySend,mm0

                movsx     eax,LeftEffectA			    ; Get 15 bit L/R Vols
				movd	  mm0,eax
                movsx     eax,RightEffectA
                movd      mm1,eax                       
				punpckldq mm0,mm1						; MM3 = RightVol LeftVol
				pi2fd	  mm0,mm0						; Convert to float
				pfmul     mm0,qword ptr SendScale 		; Multiply by 1/32768*1/32768
				movq	  EffectASend,mm0

                movsx     eax,LeftEffectB			    ; Get 15 bit L/R Vols
				movd	  mm0,eax
                movsx     eax,RightEffectB
                movd      mm1,eax                       
				punpckldq mm0,mm1						; MM3 = RightVol LeftVol
				pi2fd	  mm0,mm0						; Convert to float
				pfmul     mm0,qword ptr SendScale 		; Multiply by 1/32768*1/32768
				movq	  EffectBSend,mm0

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
;               jnz       @@k3dFilter                   ; Yope ? Use it..

;               movq      mm3,FractionHold              ; Setup fractions in MM3
;               pxor      mm4,mm4                       ; Clear MM4 (Steps)
@@k3dFilter:    
				test      Mode,1                        ; Need 16 bit mixing ?
                jnz       @@Mix16                       ; Yope ? Do it..

;******************************************************************************
;Lightspeed ]I[ mixing routines, 3DNow! optimized, 8 bit input samples.
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
				
				movq	  mm7,mm6
				punpckldq mm6,mm6

				punpckhdq mm7,mm7
				paddw     mm3,mm4

				pi2fd	  mm6,mm6
				pand	  mm3,mm5

				pi2fd     mm7,mm7
                test      edi,7
				
				movq	  mm0,mm6
                jz        @@Mix8MainEnd

				movd      mm6,ecx
                mov       ch,[esi]

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

				pfmul     mm0,DrySend
				movq	  mm2,mm1

				pfmul     mm1,EffectASend
				paddw	  mm3,mm4
				
				pfmul     mm2,EffectBSend
				paddw	  mm3,mm4

				pfadd     mm0,[edi]
				pand      mm3,mm5

				pfadd     mm1,[eax]
				movq	  mm7,mm6

				pfadd     mm2,[ebx]
				punpckldq mm6,mm6
				
				movq	  [edi],mm0
				punpckhdq mm7,mm7

				movq	  [eax],mm1
				pi2fd	  mm6,mm6

				movq	  [ebx],mm2
				pi2fd	  mm7,mm7

				add		  eax,8
				add		  ebx,8
				
				sub		  dx,1h
				add       edi,8

                sub       dx,4h
                js        @@Mix8End
@@Mix8MainLoop:
                movq      mm0,mm6
				movq	  mm1,mm6

				mov       ch,[esi]
				movq	  mm2,mm1

                shl       ecx,16
				pfmul     mm0,DrySend

                add       edx,esp
				pfmul     mm1,EffectASend

                mov       ch,[esi+1]
				pfmul     mm2,EffectBSend

                adc       esi,ebp
				pfadd     mm0,[edi]

                movd      mm6,ecx
				pfadd     mm1,[eax]

                mov       ch,[esi]
				pfadd     mm2,[ebx]
				
                shl       ecx,16
				movq	  [edi],mm0
				
                add       edx,esp
				movq	  [eax],mm1

                mov       ch,[esi+1]
				movq	  [ebx],mm2
				
				movq      mm0,mm7
				movd      mm7,ecx
			
                adc       esi,ebp
                punpckldq mm6,mm7

				pmaddwd	  mm6,mm3
				movq	  mm1,mm0

				pfmul     mm0,DrySend
				movq	  mm2,mm1

				pfmul     mm1,EffectASend
				paddw	  mm3,mm4
				
				pfmul     mm2,EffectBSend
				paddw	  mm3,mm4

				pfadd     mm0,[edi+8]
				pand      mm3,mm5

				pfadd     mm1,[eax+8]
				movq	  mm7,mm6

				pfadd     mm2,[ebx+8]
				punpckldq mm6,mm6
				
				movq	  [edi+8],mm0
				punpckhdq mm7,mm7

				movq	  [eax+8],mm1
				pi2fd     mm6,mm6

				movq	  [ebx+8],mm2
				pi2fd     mm7,mm7

                movq      mm0,mm6
				movq	  mm1,mm6

				mov       ch,[esi]
				movq	  mm2,mm1

                shl       ecx,16
				pfmul     mm0,DrySend

                add       edx,esp
				pfmul     mm1,EffectASend

                mov       ch,[esi+1]
				pfmul     mm2,EffectBSend

                adc       esi,ebp
				pfadd     mm0,[edi+16]

                movd      mm6,ecx
				pfadd     mm1,[eax+16]

                mov       ch,[esi]
				pfadd     mm2,[ebx+16]
				
                shl       ecx,16
				movq	  [edi+16],mm0
				
                add       edx,esp
				movq	  [eax+16],mm1

                mov       ch,[esi+1]
				movq	  [ebx+16],mm2
				
				movq      mm0,mm7
				movd      mm7,ecx
			
                adc       esi,ebp
                punpckldq mm6,mm7

				pmaddwd	  mm6,mm3
				movq	  mm1,mm0

				pfmul     mm0,DrySend
				movq	  mm2,mm1

				pfmul     mm1,EffectASend
				paddw	  mm3,mm4
				
				pfmul     mm2,EffectBSend
				paddw	  mm3,mm4

				pfadd     mm0,[edi+24]
				pand      mm3,mm5

				pfadd     mm1,[eax+24]
				movq	  mm7,mm6

				pfadd     mm2,[ebx+24]
				punpckldq mm6,mm6
				
				movq	  [edi+24],mm0
				punpckhdq mm7,mm7

				movq	  [eax+24],mm1
				pi2fd     mm6,mm6

				movq	  [ebx+24],mm2
				pi2fd     mm7,mm7

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
				movq      mm0,mm6
				movd	  mm6,ecx

                mov       ch,[esi]
				;

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

				pfmul     mm0,DrySend
				movq	  mm2,mm1

				pfmul     mm1,EffectASend
				paddw	  mm3,mm4
				
				pfmul     mm2,EffectBSend
				paddw	  mm3,mm4

				pfadd     mm0,[edi]
				pand      mm3,mm5

				pfadd     mm1,[eax]
				movq	  mm7,mm6

				pfadd     mm2,[ebx]
				punpckldq mm6,mm6
				
				movq	  [edi],mm0
				punpckhdq mm7,mm7

				movq	  [eax],mm1
				pi2fd	  mm6,mm6

				movq	  [ebx],mm2
				pi2fd	  mm7,mm7

				add		  eax,8
				add		  ebx,8

				add		  edi,8
				;

                sub       dx,1h
                jns       @@Mix8EndLoop

				jmp		  @@MixDone

;******************************************************************************
;Lightspeed ]I[ mixing routines, 3DNow! optimized, 16 bit input samples.
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

                movd      mm6,ecx
                mov       cx,[esi+esi]

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
				
				movq	  mm7,mm6
				punpckldq mm6,mm6

				punpckhdq mm7,mm7
				paddw     mm3,mm4

				pi2fd	  mm6,mm6
				pand	  mm3,mm5

				pi2fd     mm7,mm7
                test      edi,7
				
				movq	  mm0,mm6
                jz        @@Mix16MainEnd

				movd      mm6,ecx
                mov       cx,[esi+esi]

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

				pfmul     mm0,DrySend
				movq	  mm2,mm1

				pfmul     mm1,EffectASend
				paddw	  mm3,mm4
				
				pfmul     mm2,EffectBSend
				paddw	  mm3,mm4

				pfadd     mm0,[edi]
				pand      mm3,mm5

				pfadd     mm1,[eax]
				movq	  mm7,mm6

				pfadd     mm2,[ebx]
				punpckldq mm6,mm6
				
				movq	  [edi],mm0
				punpckhdq mm7,mm7

				movq	  [eax],mm1
				pi2fd	  mm6,mm6

				movq	  [ebx],mm2
				pi2fd	  mm7,mm7

				add		  eax,8
				add		  ebx,8
				
				sub		  dx,1h
				add       edi,8

                sub       dx,4h
                js        @@Mix16End
@@Mix16MainLoop:
                movq      mm0,mm6
				movq	  mm1,mm6

				mov       cx,[esi+esi]
				movq	  mm2,mm1

                shl       ecx,16
				pfmul     mm0,DrySend

                add       edx,esp
				pfmul     mm1,EffectASend

                mov       cx,[esi+esi+2]
				pfmul     mm2,EffectBSend

                adc       esi,ebp
				pfadd     mm0,[edi]

                movd      mm6,ecx
				pfadd     mm1,[eax]

                mov       cx,[esi+esi]
				pfadd     mm2,[ebx]
				
                shl       ecx,16
				movq	  [edi],mm0
				
                add       edx,esp
				movq	  [eax],mm1

                mov       cx,[esi+esi+2]
				movq	  [ebx],mm2
				
				movq      mm0,mm7
				movd      mm7,ecx
			
                adc       esi,ebp
                punpckldq mm6,mm7

				pmaddwd	  mm6,mm3
				movq	  mm1,mm0

				pfmul     mm0,DrySend
				movq	  mm2,mm1

				pfmul     mm1,EffectASend
				paddw	  mm3,mm4
				
				pfmul     mm2,EffectBSend
				paddw	  mm3,mm4

				pfadd     mm0,[edi+8]
				pand      mm3,mm5

				pfadd     mm1,[eax+8]
				movq	  mm7,mm6

				pfadd     mm2,[ebx+8]
				punpckldq mm6,mm6
				
				movq	  [edi+8],mm0
				punpckhdq mm7,mm7

				movq	  [eax+8],mm1
				pi2fd     mm6,mm6

				movq	  [ebx+8],mm2
				pi2fd     mm7,mm7

                movq      mm0,mm6
				movq	  mm1,mm6

				mov       cx,[esi+esi]
				movq	  mm2,mm1

                shl       ecx,16
				pfmul     mm0,DrySend

                add       edx,esp
				pfmul     mm1,EffectASend

                mov       cx,[esi+esi+2]
				pfmul     mm2,EffectBSend

                adc       esi,ebp
				pfadd     mm0,[edi+16]

                movd      mm6,ecx
				pfadd     mm1,[eax+16]

                mov       cx,[esi+esi]
				pfadd     mm2,[ebx+16]
				
                shl       ecx,16
				movq	  [edi+16],mm0
				
                add       edx,esp
				movq	  [eax+16],mm1

                mov       cx,[esi+esi+2]
				movq	  [ebx+16],mm2
				
				movq      mm0,mm7
				movd      mm7,ecx
			
                adc       esi,ebp
                punpckldq mm6,mm7

				pmaddwd	  mm6,mm3
				movq	  mm1,mm0

				pfmul     mm0,DrySend
				movq	  mm2,mm1

				pfmul     mm1,EffectASend
				paddw	  mm3,mm4
				
				pfmul     mm2,EffectBSend
				paddw	  mm3,mm4

				pfadd     mm0,[edi+24]
				pand      mm3,mm5

				pfadd     mm1,[eax+24]
				movq	  mm7,mm6

				pfadd     mm2,[ebx+24]
				punpckldq mm6,mm6
				
				movq	  [edi+24],mm0
				punpckhdq mm7,mm7

				movq	  [eax+24],mm1
				pi2fd     mm6,mm6

				movq	  [ebx+24],mm2
				pi2fd     mm7,mm7

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
				movq      mm0,mm6
				movd	  mm6,ecx

                mov       cx,[esi+esi]
				;

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

				pfmul     mm0,DrySend
				movq	  mm2,mm1

				pfmul     mm1,EffectASend
				paddw	  mm3,mm4
				
				pfmul     mm2,EffectBSend
				paddw	  mm3,mm4

				pfadd     mm0,[edi]
				pand      mm3,mm5

				pfadd     mm1,[eax]
				movq	  mm7,mm6

				pfadd     mm2,[ebx]
				punpckldq mm6,mm6
				
				movq	  [edi],mm0
				punpckhdq mm7,mm7

				movq	  [eax],mm1
				pi2fd	  mm6,mm6

				movq	  [ebx],mm2
				pi2fd	  mm7,mm7

				add		  eax,8
				add		  ebx,8

				add		  edi,8
				;

                sub       dx,1h
                jns       @@Mix16EndLoop

@@MixDone:      mov		  esp,TempESP

				femms
				
				popad

                ret
k3dMixerStereo  ENDP

k3dMixerStereoSize equ    $-k3dMixerStereo

;*******************************************************************************
;Lightspeed ]I[ digital effects routine, 3DNow! optimized, 32 bit input samples.
;*******************************************************************************

k3dReverb		PROC	  NEAR C DSPReverb: DWord, DSPDestBuffer: DWord, DSPSourceBuffer, DSPBufferSize: DWord, Flags: DWord
				pushad

				mov		  eax,DSPBufferSize
				mov		  TempEBP,eax

				mov		  esi,DSPSourceBuffer
				mov		  edi,DSPDestBuffer

				mov		  edx,DSPReverb
				mov		  ecx,dword ptr [edx+glxK3DReverb.time]

				movq	  mm0,qword ptr [edx+glxK3DReverb.leftout]
				movq	  mm4,qword ptr [edx+glxK3DReverb.apf0lpfout]
				movq	  mm5,qword ptr [edx+glxK3DReverb.apf2lpfout]
				movq	  mm6,qword ptr [edx+glxK3DReverb.apf4lpfout]

@@ReverbMainLoop:				
				movq      mm1,mm0
				psrlq	  mm0,32
	
				punpckldq mm0,mm1												; do left/right crossing

				pfadd	  mm0,qword ptr [esi]
				add		  esi,8

				pfmul	  mm0,qword ptr revoutsend

				;Update one allpass filter for left and right
				movq	  mm1,mm0
				pfmul     mm0,qword ptr [edx+glxK3DReverb.apf0gain0]			; -gain

				mov	      ebp,[edx+glxK3DReverb.td0]
				lea		  ebx,[ecx+ebp]

				mov	      ebp,[edx+glxK3DReverb.td1]
				and		  ebx,3fffh

				movd	  mm2,dword ptr [edx+ebx*8+glxK3DReverb.buf01]
				lea		  ebx,[ecx+ebp]

				pfmul	  mm4,qword ptr [edx+glxK3DReverb.apf0lpfb]
				and		  ebx,3fffh

				movd	  mm3,dword ptr [edx+ebx*8+glxK3DReverb.buf01+4]

				punpckldq mm2,mm3

				movq      mm3,mm2

				pfmul     mm3,qword ptr [edx+glxK3DReverb.apf0lpfa]
				
				pfadd     mm3,mm4

				movq	  mm4,mm3

				pfmul     mm3,qword ptr [edx+glxK3DReverb.apf0gain1]			;  gain
				
				pfadd	  mm1,mm3

				movq	  qword ptr [edx+ecx*8+glxK3DReverb.buf01],mm1
				
				pfmul	  mm2,qword ptr [edx+glxK3DReverb.apf0gain2]			;1-gain^2

				pfadd	  mm0,mm2

				;Update one allpass filter for left and right
				movq	  mm1,mm0
				pfmul     mm0,qword ptr [edx+glxK3DReverb.apf2gain0]			; -gain

				mov	      ebp,[edx+glxK3DReverb.td2]
				lea		  ebx,[ecx+ebp]

				mov	      ebp,[edx+glxK3DReverb.td3]
				and		  ebx,3fffh

				movd	  mm2,dword ptr [edx+ebx*8+glxK3DReverb.buf23]
				lea		  ebx,[ecx+ebp]

				pfmul	  mm5,qword ptr [edx+glxK3DReverb.apf2lpfb]
				and		  ebx,3fffh

				movd	  mm3,dword ptr [edx+ebx*8+glxK3DReverb.buf23+4]

				punpckldq mm2,mm3
				
				movq      mm3,mm2

				pfmul     mm3,qword ptr [edx+glxK3DReverb.apf2lpfa]
				
				pfadd     mm3,mm5

				movq	  mm5,mm3

				pfmul     mm3,qword ptr [edx+glxK3DReverb.apf2gain1]			;  gain
				
				pfadd	  mm1,mm3

				movq	  qword ptr [edx+ecx*8+glxK3DReverb.buf23],mm1
				
				pfmul	  mm2,qword ptr [edx+glxK3DReverb.apf2gain2]			;1-gain^2

				pfadd	  mm0,mm2

				;Update one allpass filter for left and right
				movq	  mm1,mm0
				pfmul     mm0,qword ptr [edx+glxK3DReverb.apf4gain0]			; -gain

				mov	      ebp,[edx+glxK3DReverb.td4]
				lea		  ebx,[ecx+ebp]

				mov	      ebp,[edx+glxK3DReverb.td5]
				and		  ebx,3fffh

				movd	  mm2,dword ptr [edx+ebx*8+glxK3DReverb.buf45]
				lea		  ebx,[ecx+ebp]

				pfmul	  mm6,qword ptr [edx+glxK3DReverb.apf4lpfb]
				and		  ebx,3fffh

				movd	  mm3,dword ptr [edx+ebx*8+glxK3DReverb.buf45+4]

				punpckldq mm2,mm3

				movq      mm3,mm2

				pfmul     mm3,qword ptr [edx+glxK3DReverb.apf4lpfa]
				
				pfadd     mm3,mm6

				movq	  mm6,mm3

				pfmul     mm3,qword ptr [edx+glxK3DReverb.apf4gain1]			;  gain
				
				pfadd	  mm1,mm3

				movq	  qword ptr [edx+ecx*8+glxK3DReverb.buf45],mm1
				
				pfmul	  mm2,qword ptr [edx+glxK3DReverb.apf4gain2]			;1-gain^2

				pfadd	  mm0,mm2

				movq	  mm7,mm0

				pfmul     mm7,qword ptr [edx+glxK3DReverb.wetleft]
				
				pfadd     mm7,qword ptr [edi]

				inc		  ecx
				and		  ecx,3fffh

				movq	  qword ptr [edi],mm7
				add		  edi,8

				dec		  TempEBP
				jnz		  @@ReverbMainLoop

				mov		  dword ptr [edx+glxK3DReverb.time],ecx
				movq	  qword ptr [edx+glxK3DReverb.leftout],mm0
				movq	  qword ptr [edx+glxK3DReverb.apf0lpfout],mm4
				movq	  qword ptr [edx+glxK3DReverb.apf2lpfout],mm5
				movq	  qword ptr [edx+glxK3DReverb.apf4lpfout],mm6
@@ReverbDone:   
				femms

                popad

                ret
k3dReverb		ENDP

;*******************************************************************************
;Lightspeed ]I[ digital effects routine, 3DNow! optimized, 32 bit input samples.
;*******************************************************************************

k3dChorus		PROC	  NEAR C DSPChorus: DWord, DSPDestBuffer: DWord, DSPSourceBuffer, DSPBufferSize: DWord, Flags: DWord
				pushad

				mov		  eax,DSPBufferSize
				mov		  edx,DSPChorus

				mov		  esi,DSPSourceBuffer
				mov		  edi,DSPDestBuffer

				mov		  ecx,dword ptr [edx+glxK3DChorus.time]
				mov		  TempEBP,eax

				movq	  mm0,qword ptr [edx+glxK3DChorus.leftout]
				;
@@ChorusMainLoop:				
				;update delay buffer
				pfmul	  mm0,qword ptr [edx+glxK3DChorus.feedbackleft]

				pfadd     mm0,qword ptr [esi]
				add		  esi,8

				movq	  qword ptr [edx+ecx*8+glxK3DChorus.buf01],mm0

				;process first voice
				mov		  ebx,[edx+glxK3DChorus.phase0]
				;
				
				shr		  ebx,6
				;
				
				mov		  ebx,[edx+ebx*4+glxK3DChorus.wave]
				;
				
				sar		  ebx,15
				;
				
				add		  ebx,ecx
				;
				
				and		  ebx,3fffh
				;
				
				movq	  mm0,qword ptr [edx+ebx*8+glxK3DChorus.buf01]
				;

				;process second voice
				mov		  ebx,[edx+glxK3DChorus.phase1]
				;

				shr		  ebx,6
				;

				mov		  ebx,[edx+ebx*4+glxK3DChorus.wave]
				;

				sar		  ebx,15
				;

				add		  ebx,ecx
				;

				and		  ebx,3fffh
				;

				movq	  mm1,qword ptr [edx+ebx*8+glxK3DChorus.buf01]
				;

				;mix left/right
				pfacc	  mm0,mm1
				;
				
				;update voice LFOs
				mov		  eax,[edx+glxK3DChorus.speed]
				;

				add		  [edx+glxK3DChorus.phase0],eax
				;

				add		  [edx+glxK3DChorus.phase1],eax
				;

				and		  [edx+glxK3DChorus.phase0],65535
				;

				and		  [edx+glxK3DChorus.phase1],65535
				;

				;Add to output (do dry/wet stuff)
				movq	  mm1,mm0

				pfmul     mm1,qword ptr [edx+glxK3DChorus.wetleft]
				inc		  ecx
				
				pfadd     mm1,qword ptr [edi]
				and		  ecx,3fffh
				
				movq	  qword ptr [edi],mm1
				add		  edi,8

				dec		  TempEBP
				jnz		  @@ChorusMainLoop

				movq	  qword ptr [edx+glxK3DChorus.leftout],mm0

				mov		  dword ptr [edx+glxK3DChorus.time],ecx
@@ChorusDone:
				femms		

				popad
				 
				ret
k3dChorus		ENDP

;******************************************************************************
;Lightspeed ]I[ post process routines, K6 3D optimized, 32 bit input samples.
;******************************************************************************

k3dConvert      PROC      NEAR C InBuffer: DWord, InCount: DWord, OutBuffer: DWord, Mode: Byte
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
				pf2id     mm0,qword ptr [esi]
				;

				pf2id     mm1,qword ptr [esi+8]
				;

				pf2id     mm2,qword ptr [esi+16]
				;

				pf2id     mm3,qword ptr [esi+24]
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
				movd      mm0,dword ptr [esi]
				add	      esi,4
				
				movsx	  eax,byte ptr [edi]
				pf2id     mm0,mm0

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
				pf2id     mm0,qword ptr [esi]
				;

				pf2id     mm1,qword ptr [esi+8]
				;

				pf2id     mm2,qword ptr [esi+16]
				;

				pf2id     mm3,qword ptr [esi+24]
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
				movd      mm0,dword ptr [esi]
				add	      esi,4
				
				pf2id     mm0,mm0
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
				pf2id     mm0,qword ptr [esi]
				;

				pf2id     mm1,qword ptr [esi+8]
				;

				pf2id     mm2,qword ptr [esi+16]
				;

				pf2id     mm3,qword ptr [esi+24]
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
				movd      mm0,dword ptr [esi]
				add	      esi,4

				movsx	  eax,word ptr [edi]
				pf2id     mm0,mm0

				movd	  mm1,eax
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
				pf2id     mm0,qword ptr [esi]
				;

				pf2id     mm1,qword ptr [esi+8]
				;

				pf2id     mm2,qword ptr [esi+16]
				;

				pf2id     mm3,qword ptr [esi+24]
				packssdw  mm0,mm1
				
				;
				;

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
				movd      mm0,dword ptr [esi]
				;
				
				pf2id     mm0,mm0
				add	      esi,4

				movd	  eax,mm0
				;

				mov       word ptr [edi],ax
				add       edi,2
				
				sub		  ebp,1h
				jns		  @@Conv16EndLoop

@@ConvDone:		femms

                popad

                ret
k3dConvert      ENDP

k3dConvertSize  equ       $-k3dConvert

;******************************************************************************
;Lightspeed ]I[ mixing init. routines, K6 3D optimized.
;******************************************************************************

                PUBLIC C  k3dMixerInit

k3dMixerInit    PROC      NEAR C MixType: Byte,VolumeBase: DWord,MixerBase: DWord
                push      ebx
                push      ecx
                push      edx
                push      esi
                push      edi
                cld
                mov       eax,[VolumeBase]
                mov       ebx,[MixerBase]
                mov       ecx,k3dMixerStereoSize
                mov       esi,offset k3dMixerStereo
                mov       edi,ebx
                rep       movsb
                mov       eax,edi
                mov       ecx,k3dConvertSize
                mov       esi,offset k3dConvert
                rep       movsb
                pop       edi
                pop       esi
                pop       edx
                pop       ecx
                pop       ebx
                ret
k3dMixerInit    ENDP

;***************************************************************************************
;Lightspeed ]I[ IDCT 64x32 routines, 3DNow! optimized, 32 bit input, 16 bit output
;***************************************************************************************

;short *bandPtr;
;int channel;
;short *samples;
;udword *V;

k3dIDCT64x32    PROC      NEAR C Input: DWord, Channel: Byte, Output: DWord, V: DWord
				pushad

				mov		  ecx,Input
;				mov		  edx,Temp

				;Input butterflies (even part)
				movq	  mm0,qword ptr [ecx+30*4]								; 31 30
				punpckldq mm1,mm0												; 30 XX
				punpckhdq mm0,mm1												; 30 31
				pfadd	  mm0,qword ptr [ecx+ 0*4]								; 30+ 1  31+ 0

				movq	  mm2,qword ptr [ecx+14*4]								; 15 14
				punpckldq mm3,mm2												; 14 XX
				punpckhdq mm2,mm3												; 14 15
				pfadd	  mm2,qword ptr [ecx+16*4]								; 17+14  16+15

				movq	  mm4,qword ptr [ecx+28*4]								; 29 28
				punpckldq mm5,mm4												; 28 XX
				punpckhdq mm4,mm5												; 28 29
				pfadd	  mm4,qword ptr [ecx+ 2*4]								; 28+ 3  29+ 2

				movq	  mm6,qword ptr [ecx+12*4]								; 13 12
				punpckldq mm7,mm6												; 12 XX
				punpckhdq mm6,mm7												; 12 13
				pfadd	  mm6,qword ptr [ecx+18*4]								; 19+12  18+13
								
				movq	  mm1,mm0												; 30+ 1  31+ 0
				pfadd     mm0,mm2												; EE[1..0]
				pfsub	  mm1,mm2												; EO[1..0]

				movq	  mm5,mm4												; 28+ 3  29+ 2
				pfadd	  mm4,mm6												; EE[3..2]
				pfsub     mm5,mm6												; EO[3..2]
								
				movq      qword ptr [edx+ 0*4],mm0
				movq	  qword ptr [edx+ 2*4],mm4
				movq	  qword ptr [edx+ 8*4],mm1
				movq	  qword ptr [edx+10*4],mm5

				movq	  mm0,qword ptr [ecx+26*4]								; 27 26
				punpckldq mm1,mm0												; 26 XX
				punpckhdq mm0,mm1												; 26 27
				pfadd	  mm0,qword ptr [ecx+ 4*4]								; 26+ 5  27+ 4

				movq	  mm2,qword ptr [ecx+10*4]								; 11 10
				punpckldq mm3,mm2												; 10 XX
				punpckhdq mm2,mm3												; 10 11
				pfadd	  mm2,qword ptr [ecx+20*4]								; 21+10  20+11

				movq	  mm4,qword ptr [ecx+24*4]								; 25 24
				punpckldq mm5,mm4												; 24 XX
				punpckhdq mm4,mm5												; 24 25
				pfadd	  mm4,qword ptr [ecx+ 6*4]								; 24+ 7  25+ 6

				movq	  mm6,qword ptr [ecx+ 8*4]								;  9  8
				punpckldq mm7,mm6												;  8 XX
				punpckhdq mm6,mm7												;  8  9
				pfadd	  mm6,qword ptr [ecx+22*4]								; 23+ 8  22+ 9
								
				movq	  mm1,mm0												; 26+ 5  27+ 4
				pfadd     mm0,mm2												; EE[5..4]
				pfsub	  mm1,mm2												; EO[5..4]

				movq	  mm5,mm4												; 24+ 7  25+ 6
				pfadd	  mm4,mm6												; EE[7..6]
				pfsub     mm5,mm6												; EO[7..6]
								
				movq      qword ptr [edx+ 4*4],mm0
				movq	  qword ptr [edx+ 6*4],mm4
				movq	  qword ptr [edx+12*4],mm1
				movq	  qword ptr [edx+14*4],mm5
				
				;input butterfly (odd part, delivers NEGATIVE odd !!!)
				movq	  mm0,qword ptr [ecx+30*4]								; 31 30
				punpckldq mm1,mm0												; 30 XX
				punpckhdq mm0,mm1												; 30 31
				pfsub	  mm0,qword ptr [ecx+ 0*4]								; 30- 1  31- 0
				movq	  qword ptr [edx+16*4],mm0			

				movq	  mm0,qword ptr [ecx+28*4]								; 29 28
				punpckldq mm1,mm0												; 28 XX
				punpckhdq mm0,mm1												; 28 29
				pfsub	  mm0,qword ptr [ecx+ 2*4]								; 28- 3  29- 2
				movq	  qword ptr [edx+18*4],mm0			

				movq	  mm0,qword ptr [ecx+26*4]								; 27 26
				punpckldq mm1,mm0												; 26 XX
				punpckhdq mm0,mm1												; 26 27
				pfsub	  mm0,qword ptr [ecx+ 4*4]								; 26- 5  27- 4
				movq	  qword ptr [edx+20*4],mm0			

				movq	  mm0,qword ptr [ecx+24*4]								; 25 24
				punpckldq mm1,mm0												; 24 XX
				punpckhdq mm0,mm1												; 24 25
				pfsub	  mm0,qword ptr [ecx+ 6*4]								; 24- 7  25- 6
				movq	  qword ptr [edx+22*4],mm0			

				movq	  mm0,qword ptr [ecx+22*4]								; 23 22
				punpckldq mm1,mm0												; 22 XX
				punpckhdq mm0,mm1												; 22 23
				pfsub	  mm0,qword ptr [ecx+ 8*4]								; 22- 9  23- 8
				movq	  qword ptr [edx+24*4],mm0			

				movq	  mm0,qword ptr [ecx+20*4]								; 21 20
				punpckldq mm1,mm0												; 20 XX
				punpckhdq mm0,mm1												; 20 21
				pfsub	  mm0,qword ptr [ecx+10*4]								; 20-11  21-10
				movq	  qword ptr [edx+26*4],mm0			
			
				movq	  mm0,qword ptr [ecx+18*4]								; 19 18
				punpckldq mm1,mm0												; 18 XX
				punpckhdq mm0,mm1												; 18 19
				pfsub	  mm0,qword ptr [ecx+12*4]								; 18-13  19-12
				movq	  qword ptr [edx+28*4],mm0			

				movq	  mm0,qword ptr [ecx+16*4]								; 17 16
				punpckldq mm1,mm0												; 16 XX
				punpckhdq mm0,mm1												; 16 17
				pfsub	  mm0,qword ptr [ecx+14*4]								; 16-15  17-14
				movq	  qword ptr [edx+30*4],mm0			

				;EDX : EE,EO,O
				;Now do 8x8 matrix mul with EE and EO
				;    do 16x16 matrix mul with MINUS O !!

				;output reordering
				movq	  mm0,qword ptr [edx+ 4*4]								; EE[5..4]
				movq	  mm1,qword ptr [edx+12*4]								; EO[5..4]

				movq	  mm2,mm0								
				punpckldq mm0,mm1												; EO4 EE4
											
				movq	  mm3,qword ptr [edx+24*4]								; ODD[9..8]
				movq	  mm4,mm0												; Duplicate
	
				punpckldq mm0,mm3												; ODD8 EE4
				punpckhdq mm4,mm3												; ODD9 EO4

				punpckhdq mm2,mm1												; EO5 EE5
				movq	  mm3,qword ptr [edx+26*4]								; ODD[11..10]
				
				movq	  mm5,mm2				
				
				punpckldq mm2,mm3												; ODD10 EE5
				punpckhdq mm5,mm3												; ODD11 EO5

				movq	  qword ptr [ecx+ 0*4],mm0
				movq	  qword ptr [ecx+ 2*4],mm4
				movq	  qword ptr [ecx+ 4*4],mm2
				movq	  qword ptr [ecx+ 6*4],mm5




				popad
				ret
k3dIDCT64x32	ENDP


.DATA

TempEBP			dd		  0
TempESP			dd		  0
DrySend			dq		  0
EffectASend		dq		  0
EffectBSend		dq		  0
FractionMask	dq		  07fff7fff7fff7fffh
FractionHold	dq		  07fff00007fff0000h
SendScale		dd		  30800000h,30800000h									; 1/32768*1/32768
revoutsend		dd		  3f000000h,3f000000h									; 1/2
revoutsend2		dd		  3eaaaaabh,3eaaaaabh
dither8			dw		  0080h,0080h,0080h,0080h		  

                END
